//
//  UploadImageViewController.h
//  aventador
//
//  Created by Aldrich Wingsiong on 2014-04-21.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>
#import "UIImage+Utilities.h"
#import "FXBlurView.h"
#import "Post.h"

@protocol PostDelegate <NSObject>
- (void) newPostCreated;
@end

@interface UploadImageViewController : UIViewController 
//declared the two delegates we'll be using, UIImagePickerControllerDelegate and Nav Controller Delegate
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPageViewControllerDataSource>{
    BOOL cameraSourceChosen;
    BOOL librarySourceChosen;
    
    //geolocation variables
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    CLLocationManager *locationManager;
}

@property NSString *imageName;
@property UIImage *imageToUpload;

// POST BODY
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *geotagLabel;

//Delegate to handle new post
@property id<PostDelegate>delegate;

// Page Controller Variables
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableDictionary *stockImages;
@property (strong, nonatomic) NSMutableArray *imageOrder;

@property (strong, nonatomic) UIImage *userChosenImage;

- (IBAction)unwindToUploadImageView:(UIStoryboardSegue *)segue;

@end
