#include "tracking.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <iostream>

// include constants here:
const int edgeparam = 400; // input of function EdgeDetect (thresh = edgeparam)
int frcounter = 1; // counter for saving only every 30th image

// functions

void SvImage(IplImage* img, char* filename)
{
    int p[3] = {CV_IMWRITE_JPEG_QUALITY,95,0};
    cvSaveImage(filename, img, p);
}

IplImage* CrossTarget (IplImage* inImg, int x, int y, int size, int line_thickness)
{	
    // ******* already completely implemented for you, you don't need to change anything here *******
    IplImage* outImg = cvCloneImage(inImg);
    /* We use opencv function called "cvLine" to create a cross on the given coordinate (x,y)
     * This function is used in color tracking image. You will integrate this function into the color tracking function during the lab
     * You can find the defintion of cvLine from the website.	 *
     */
    
    // horizontal line
    CvPoint pt1 = cvPoint(x-size/2,y);
    CvPoint pt2 = cvPoint(x+size/2,y);
    cvLine(outImg, pt1, pt2, cvScalar(0, 200,0), line_thickness, 8, 0);
    // verical line
    pt1.x = x; pt1.y = y-size/2;
    pt2.x = x; pt2.y = y+size/2;
    cvLine(outImg, pt1, pt2, cvScalar(0,200,0), line_thickness, 8, 0);
    
    
    return outImg;
}

int ColorTrackingSetColors(IplImage* img, int* hmax, int* hmin, int* smax, int* smin, int* vmax, int* vmin)
 {  
    // ******** PostLab Q1 *********
    /* This function will allow us to manually set the thresholds, while observing the result.
       The example code on color tracking with OpenCV in the lab manual can be used as a reference.*/

    // Create a new image with the same size as IplImage* img, a depth of 8 and appropriate number of channels
    // Call that new image "imgHSV"
    //IplImage* imgHSV, imgShow, imgThresh;
    
	IplImage* imgHSV = cvCreateImage(cvGetSize(img), 8, 3);

    // Convert Source Image to HSV, use cvCvtColor()
    // make sure to store the converted image in "imgHSV"
	cvCvtColor(img,imgHSV, CV_RGB2HSV);

    // Create Threshold Trackbars using cvCreateTrackbar()
    // the window_name can be any name (e.g. "Set"), just make sure that a window with the same name is created in main()
	cvCreateTrackbar("HueMin", "Track", hmin, 256, 0);
	cvCreateTrackbar("HueMax", "Track", hmax, 256, 0);
	cvCreateTrackbar("SatMin", "Track", smin, 256, 0);
	cvCreateTrackbar("SatMax", "Track", smax, 256, 0);
	cvCreateTrackbar("ValMin", "Track", vmin, 256, 0);
	cvCreateTrackbar("ValMax", "Track", vmax, 256, 0);

    // Create a new image to apply thresholds and one to save the mask
    // call the mask "imgThresh" and the masked image "imgShow"
    IplImage* imgShow = cvCreateImage(cvGetSize(img), 8, 3);
    IplImage* imgThresh = cvCreateImage(cvGetSize(img), 8, 1);

    // Threshold the image using the function cvInRangeS() and save the mask in imgThresh (already done)
    cvInRangeS(imgHSV, cvScalar(*hmin,*smin,*vmin), cvScalar(*hmax,*smax,*vmax), imgThresh);

    // filter the original image using our mask, save the filtered image in imgShow
    // use the function cvCopy()
    
    cvCopy(img, imgShow, imgThresh);


    // Display the filtered image imgShow using the function cvShowImage()
	cvShowImage("Track",imgShow);

    // Release created Images (HSV image, filtered image and threshed/mask image)
    // use the function vcReleaseImage()
	cvReleaseImage(&imgShow);
	cvReleaseImage(&imgThresh);
	cvReleaseImage(&imgHSV);

    return 0;
}

int ColorTracking (IplImage* img, int* positionX , int* positionY, CvScalar min, CvScalar max)
{
    // ******** PostLab Q2 ************
    /* In this funczion we will implement our Color Tracking algorithm
       The thresholds min and max are passed to the function and are determined beforehad uising ColorTrackingSetColors*/
       

    // Create new HSV image
    IplImage* newHSV = cvCreateImage(cvGetSize(img), 8, 3);

    // Convert Source Image to HSV (with parameters cv::COLOR_BGR2HSV)
	cvCvtColor(img, newHSV, cv::COLOR_BGR2HSV);
    // Create new image to apply thresholds
    IplImage* imgThresh = cvCreateImage(cvGetSize(img), 8, 1);

    // Threshold the image with CvScalar min and CvScalar max
	cvInRangeS(newHSV, min, max, imgThresh);

    // Create memory space for moments
    CvMoments *moments_y = (CvMoments*)malloc(sizeof(CvMoments));

    // Calculate moments
    cvMoments(imgThresh,moments_y,1);

    // Extract spatial moments and area
    double moment10_y = moments_y->m10;
    double moment01_y = moments_y->m01;
    double area_y = moments_y->m00;

    // Determine Center (see: https://docs.opencv.org/3.1.0/d8/d23/classcv_1_1Moments.html)
	*positionX = moment10_y/area_y;
	*positionY = moment01_y/area_y;

    // Add a cross at center using the function (CrossTarget())
    // you can use cvCloneImage to duplicate the original image
    //IplImage* clone = cvCloneImage(img);
	IplImage* clone=CrossTarget(img,*positionX,*positionY,16,1);

    // display the image (the one with the cross)
	cvShowImage("Track",clone);

    // save the the image
    // uncomment the following code and use the correct image
    /*if (frcounter%30 == 0)
    {
        char filename[50];
        sprintf(filename,"Crossed_frame%d.jpg",frcounter);
        SvImage(image,filename);
    }*/

    // Release created images and free (free()) memory (moments_y)
	free(moments_y);
	cvReleaseImage(&imgThresh);
	cvReleaseImage(&newHSV);
	cvReleaseImage(&clone);

    return 0;
}

int EdgeDetect (IplImage* img, int thresh) 
{   // ********** Prelab Q2 ***********
    // note: you can find the function definitions online under https://docs.opencv.org/2.4/index.html
	
    // Create a new image for converting the  original image to gray image. Use cvCreateImage() and assign
    // it to variable called "gray_img" of type IplImage*. Use cvGetSize(img) within cvCreateImage() to get the right size
    // If you are not sure, you can refer to the example in the lab manual.
	
	IplImage* gray_img = cvCreateImage(cvGetSize(img), 8, 1);
	
	 
	
    // Convert your image "img" to gray (store it in "gray_img") with the function cvCvtColor(), using the parameters called cv::COLOR_BGR2GRAY
	
	cvCvtColor(img, gray_img, cv::COLOR_BGR2GRAY);
    
    // Smooth the gray image by using "cvSmooth" function and using gaussian method (CV_GAUSSIAN).
    // Make sure to create a new image called "smooth_gray_img" first (cvCreateImage) where you can store the smoothed image
	
	IplImage* smooth_gray_img = cvCreateImage(cvGetSize(img), 8, 1);
	cvSmooth(gray_img, smooth_gray_img, CV_GAUSSIAN);

	// Create another new image called "edge_detect" which we will use for edge detection from the converted gray image
	IplImage* edge_detect = cvCreateImage(cvGetSize(img), 8, 1);
	
	 
    // Detect edges using canny edge detection by using "cvCanny" function with the parameter of thresh to define the range. Use "thresh" for the
    // first threshold for the hysteresis procedure and "thresh*2" for the second treshhold for the hysteris procedure and an aperture size of 3.
    // refer to https://docs.opencv.org/2.4/modules/imgproc/doc/feature_detection.html?highlight=canny#cv.Canny
    cvCanny(gray_img, edge_detect, thresh, thresh*2, 3); 
	
	
	
	// Create variables to store contours (already done)
	CvMemStorage *mem;
	mem = cvCreateMemStorage(0);
	CvSeq *contours = 0;

	// Find contours in the canny output using the cvFindContours() function
	cvFindContours(edge_detect, mem, &contours, sizeof(CvContour), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
		
	// Create a new image called "edge_img" for storing edge tracking image from gray image. Use 3 channels.
	IplImage* edge_img = cvCreateImage(cvGetSize(img), 8, 3);
	
    // define the color of the contour using cvScalar (make sure it's consistent with the number of channels)
	//cvScalar(0,0,255); //red color, bgr
	cv::Scalar color = cv::Scalar(0,0,255);
    //define the color of contours using cvScalar()


	while (contours != 0)
	{
		// draw  contours by using the cvDrawContours() function
        // set maxLevel = 0
        //cvScalar maxLevel = 0;
		cvDrawContours(edge_img, contours, color, color,0); //I define the color here instead, not sure if correct
		
        // pointer to the next sequence
		contours = contours->h_next;
	}
		
	// Display images by using cvShowImage() function
	//cvShowImage("gray image",gray_img);
	//cvShowImage("smooth gray image",smooth_gray_img);
	//cvShowImage("edge detect",edge_detect);
	cvShowImage("edge image",edge_img);
	
	
	
    // Save Images (already done, just uncomment)
    
    if (frcounter%30 == 0)
    {
        char filename[50];
        sprintf(filename,"Contour_frame%d_%d.jpg",frcounter,edgeparam);
        SvImage(edge_img,filename);
    }
    
	
	//release the used images by using cvReleaseImage() function. Pass the address of your image pointers to cvReleaseImage
  	cvReleaseImage(&gray_img);
	cvReleaseImage(&smooth_gray_img);
	cvReleaseImage(&edge_detect);
	cvReleaseImage(&edge_img);
		
	return 0;	
}


int main ()
{
	// Variable initialization		
	IplImage* frame = 0;

    // ************* PostLab Q1 ************ //

	//open the .avi file using cvCaptureFromFile()
	//CvCapture*
	CvCapture *capture = cvCaptureFromFile("capture.avi");

    if (!capture)
    {
        printf("Could not initialize capturing...\n");
        return -1;
    }
	
    /******* set color tracking parameters  *******/
    // in this part of our program we want to use the function ColorTrackingSetColors() 
    // to specify the color tracking parameters for the color tracking algorithm


    // create a window using cvNameWindow() for setting the color tracking parameters, make sure to use the same window name as in ColorTrackingSetColors()
    cvNamedWindow("Track",CV_WINDOW_AUTOSIZE);
    IplImage *img = cvCreateImage(cvSize(640,480),8,3);
    

    // write a while loop that loops over all the frames in the .avi file and calls the function ColorTrackingSetColors() on each of them
    // once at the end, start again until the user presses any key
    int hmax = 255;
    int smax = 255;
    int vmax = 255;
    int vmin = 0;
    int smin = 77;
    int hmin = 68;
    int i;
    int positionX = 0;
    int positionY = 0;
    while (1)
    {
		break;
		cv::Scalar min = cv::Scalar(hmin,smin,vmin);
		cv::Scalar max = cv::Scalar(hmax,smax,vmax);
		
		i++;
		if(i>=239){
			i = 0;
		}
		
		
        // use cvQueryFrame() to grab a single video frame
        frame = cvQueryFrame(capture);
        // use cvSetCaptureProperty() to start again from the beginning if necessary
        cvSetCaptureProperty(capture, CV_CAP_PROP_POS_FRAMES,i);
        
        cvCopy(frame,img);
        //cvShowImage("Track",img);
        //cvReleaseImage(&img);
        
        ColorTrackingSetColors(img, &hmax, &hmin, &smax, &smin, &vmax, &vmin);
        
        // cvWaitKey(10) can be used to receive user inputs
		char c = cvWaitKey(10);
		if(c == 27)
			break;
    }

    // close the window
	cv::destroyAllWindows();

    // ************* PostLab Q2 ************ //

    /******* color tracking algorithm ******/
    // similar to before, call the ColorTracking() function on each frame of the .avi file
    // to track the red dot, also use your color tracking parameters you specified before
    // make sure to display (show images) how the dot is being tracked

    // write the coordinates of the center of the red dot in a text file
	
		FILE *coordinate;
		coordinate = fopen("Coordinates.txt", "w");
	
		while(1){
		break;
		cv::Scalar min = cv::Scalar(hmin,smin,vmin);
		cv::Scalar max = cv::Scalar(hmax,smax,vmax);
		
		i++;
		if(i>=239){
			i = 0;
		}
		
		
        // use cvQueryFrame() to grab a single video frame
        frame = cvQueryFrame(capture);
        // use cvSetCaptureProperty() to start again from the beginning if necessary
        cvSetCaptureProperty(capture, CV_CAP_PROP_POS_FRAMES,i);
        
        cvCopy(frame,img);
        
        ColorTracking (img, &positionX , &positionY, min,max);
		
		
		fprintf(coordinate, "%d %d\n",(int)positionX,(int)positionY);

        // cvWaitKey(10) can be used to receive user inputs
		char c = cvWaitKey(10);
		if(c == 27)
			break;
    }
    fclose(coordinate);

   


    while (1)
    {
		
		cv::Scalar min = cv::Scalar(hmin,smin,vmin);
		cv::Scalar max = cv::Scalar(hmax,smax,vmax);
		
		frcounter++;
		i++;
		if(i>=239){
			i = 0;
		}
		
		
        // use cvQueryFrame() to grab a single video frame
        frame = cvQueryFrame(capture);
        // use cvSetCaptureProperty() to start again from the beginning if necessary
        cvSetCaptureProperty(capture, CV_CAP_PROP_POS_FRAMES,i);
        
        cvCopy(frame,img);
        
        
		EdgeDetect(img,edgeparam);
		

        // cvWaitKey(10) can be used to receive user inputs
		char c = cvWaitKey(10);
		if(c == 27)
			break;
    }


	
	//release the used images and capture
    // make sure to close all windows


	
	return 0;
}


