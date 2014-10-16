//
//  CommentsWrapperViewController.m
//  Comments
//
//  Created by Mark Ye on 2014-05-06.
//  Copyright (c) 2014 Mark Ye. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "DetailedViewController.h"
#import "CommentTableViewCell.h"
#import "Comment.h"
#import "Constants.h"
#import "Post.h"
#include <stdlib.h>
#import "UIColor+HexColors.h"
#import "AMSmoothAlertView.h"
#import "AMSmoothAlertConstants.h"

#define HEADER_HEIGHT 320.0f
#define HEADER_INIT_FRAME CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)
#define TOOLBAR_INIT_FRAME CGRectMake (0, 292, 320, 22)

const CGFloat kBarHeight = 50.0f;
const CGFloat kBackgroundParallexFactor = 0.5f;
const CGFloat kBlurFadeInFactor = 0.005f;
const CGFloat kTextFadeOutFactor = 0.05f;
const CGFloat kCommentCellHeight = 50.0f;

@interface DetailedViewController ()

// Flagging Button
@property (weak, nonatomic) IBOutlet UIButton *flagButton;

@end

@implementation DetailedViewController

    NSMutableArray * comments;
    UIImageView * topImage;
    UIView * overlayView;
    const NSString *COMMENT_PROMPT = @"Share your thoughts!";

    // variables to store the default position and size of UI objects
    CGRect originalCoordinates;
    CGRect originalTableCoordinates;
    CGFloat originalImageHeight;
    bool firstTime = true;
    bool responseViewGone = true;

    NSMutableDictionary *user_colour;
    NSArray * color_hexcodes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    
    // Must Deallocate to prevent exec_bad_access from occuring when clicking on back in the middle of a "viewDidScroll call"
    [self.backgroundScrollView setDelegate:nil];
    [self.commentsTable setDelegate:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Comments, View Did Load");
    
    comments = [[NSMutableArray alloc] init];
    comments = [self.post.comments mutableCopy];
    
    Comment *fillerCommentForSpaceAtBottom = [Comment new];
    fillerCommentForSpaceAtBottom.message = @"";
    fillerCommentForSpaceAtBottom.user_id = [NSNumber numberWithInt:-123];
    [comments addObject:fillerCommentForSpaceAtBottom];
    
    self.postLabel.text = self.post.message;
    self.postLabel.textColor = [UIColor whiteColor];
    self.postImage.image = self.image;
    
    /*self.postImage.contentMode = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _postImage.image = [self resizeImage:_postImage.image scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.width)];
    _postImage.frame = CGRectMake(0.0f, 0.0f, self.postImage.image.size.width, self.postImage.image.size.height);
    _postImage.bounds = CGRectMake(0.0f, 0.0f, self.postImage.image.size.width, self.postImage.image.size.height);
    //_postImage.contentMode = UIViewContentModeScaleAspectFit;
    _postImage.clipsToBounds = true;*/
    
    
    overlayView = [[UIView alloc]init];
    overlayView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:overlayView];
    overlayView.hidden = true;
    
    topImage = [[UIImageView alloc]init];
    topImage.image = self.image;
    topImage.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.width);
    [self.view addSubview:topImage];
    topImage.hidden = true;
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.responseView.frame.size.width, 0.5f);
    topBorder.backgroundColor = [UIColor grayColor].CGColor;
    [self.responseView.layer addSublayer:topBorder];
    
    originalCoordinates = CGRectMake(_postImage.frame.origin.x, _postImage.frame.origin.y, _postImage.frame.size.width, _postImage.frame.size.height);
    originalTableCoordinates = CGRectMake(_commentsTable.frame.origin.x, _commentsTable.frame.origin.y, _commentsTable.frame.size.width, _commentsTable.frame.size.height);
    
    // Colour Array of Hex
    color_hexcodes = [[NSArray alloc] initWithObjects:@"0077B5",
                                @"DD731D",
                                @"9E0270",
                                @"890338",
                                @"2D86C0",
                                @"64B504",
                                @"CDA21B",
                                @"D5249D",
                                @"DD3833",
                                @"201D5A",
                                @"3A8D93",
                                @"7B17EA",
                                @"E76A67",
                                @"2924CF",
                                @"3D2CFF",
                                @"F3CC41",
                                @"008281",
                                @"891F8F",
                                @"27BAF1",
                                @"474143",
                                @"4F1902",
                                @"A39C91",
                                @"4A408E",
                                @"A4F112", nil];
    
    // User-id --> Hex Colour (index number in the NSArray)
    user_colour = [[NSMutableDictionary alloc] init];
    
    // set up the keyboard
    [self registerForKeyboardNotifications];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self.responseButton addTarget:self action:@selector(responseButtonClicked:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    
    NSLog(@"Comments, View Finished Did Load");
    [self.commentsTable reloadData];
}

-(void) viewWillAppear:(BOOL)animated{
    self.responseView.hidden = false;
    UIView * footerView = [[UIView alloc]init];
    footerView.frame = CGRectMake(footerView.frame.origin.x, footerView.frame.origin.y, self.responseView.frame.size.width, self.responseView.frame.size.height);
    self.commentsTable.tableFooterView = footerView;
}

- (void)viewDidAppear:(BOOL)animated{
    [_backgroundScrollView setScrollEnabled:YES];
    //[_backgroundScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    [_backgroundScrollView setBounces:true];
    [_commentsTable setScrollEnabled:false];
    
    [_backgroundScrollView setShowsVerticalScrollIndicator:NO];
    _backgroundScrollView.contentSize = CGSizeMake(self.view.frame.size.width, topImage.frame.size.height + _commentsTable.contentSize.height);
    
    //NSLog([NSString stringWithFormat:@"%f", _postImage.frame.size.height]);
    originalImageHeight = _postImage.frame.size.height;
    //[self.backgroundScrollView insertSubview:signUpView.view atIndex:[items count] - 1];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [comments count];
}

bool topImageSet = false;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    float top_offset = 0.0f;
    if(scrollView == self.commentsTable) {
        return;
    }
    else if(scrollView == self.backgroundScrollView) {
    }
    CGFloat delta = _backgroundScrollView.contentOffset.y;
    
    if (delta + top_offset > 250.0f) {
        if (!topImageSet) {
            topImage.frame = CGRectMake(_postImage.frame.origin.x, _postImage.frame.origin.y - delta, _postImage.frame.size.width, _postImage.frame.size.height);
            overlayView.frame = topImage.frame;
            topImage.alpha = _postImage.alpha;
            topImageSet = true;
        }
        topImage.hidden = false;
        overlayView.hidden = false;
    } else {
        
        _postImage.alpha = 1.0f - 0.0025f * (delta + top_offset);
        topImage.hidden = true;
        overlayView.hidden = true;
        topImageSet = false;
    }
    
    // disable bounce at the top
    if (scrollView.contentOffset.y <= -top_offset) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -top_offset)];
    }
    
    // check if we reached the bottom
    [self responseViewHideCheck:scrollView keyboardJustHidden:false];
}

-(void) responseViewHideCheck:(UIScrollView*)scrollView keyboardJustHidden:(bool)keyboardJustHidden
{
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
        // show the response bar at the bottom of the screen
        if (responseViewGone || keyboardJustHidden) {
            self.responseView.hidden = false;
            responseViewGone = false;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            self.responseView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height - self.responseView.frame.size.height, self.responseView.frame.size.width, self.responseView.frame.size.height);
            [UIView commitAnimations];
        }
    }
    else {
        if (!responseViewGone || keyboardJustHidden) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            self.responseView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height + self.responseView.frame.size.height, self.responseView.frame.size.width, self.responseView.frame.size.height);
            [UIView commitAnimations];
            responseViewGone = true;
            //self.responseView.hidden = true;
        }
    }
}

/*
 * this gets the cell view at a certain location in the table
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *cell = (CommentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CommentTableCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CommentTableCell"];
    }
    
    Comment *c = (Comment*) [comments objectAtIndex:indexPath.row];
    
    //CGFloat height = cell.frame.size.height;
    //CGPoint origin = cell.frame.origin;
    //cell.commentText.frame = CGRectMake(cell.commentText.frame.origin.x, 5.0f, cell.commentText.frame.size.width, height - 10.0f);
    
    
    // Don't set anything for the filler
    if ([c.user_id intValue] == -123) {
        cell.profileIconImageView.hidden = YES;
        cell.backgroundColorView.hidden = YES;
    }
    else {
        // Set background colour
        if ([user_colour objectForKey:[c.user_id stringValue]] == nil) {
            // Background colour hasn't been assigned yet, do that now
            int r = arc4random() % color_hexcodes.count;
            NSString *hex = color_hexcodes[r];
            [user_colour setObject:hex forKey:[c.user_id stringValue]];
            UIColor *bkgdColor = [UIColor colorWithHexString:hex];
            cell.backgroundColorView.backgroundColor = bkgdColor;
        }
        else {
            cell.backgroundColorView.backgroundColor = [UIColor colorWithHexString:[user_colour objectForKey:[c.user_id stringValue]]];
        }
    }
    
    cell.backgroundColorView.layer.cornerRadius = 5.0f;
    
    /*
    cell.speechTriangleIcon.image = [UIImage imageNamed:@"bubble-arrow.png"];
    cell.speechTriangleIcon.frame = CGRectMake(cell.speechTriangleIcon.frame.origin.x, height / 2 - cell.speechTriangleIcon.frame.size.height / 2, cell.speechTriangleIcon.frame.size.width, cell.speechTriangleIcon.frame.size.height);
    NSLog(@"%f %f %f", origin.y, height / 2, cell.speechTriangleIcon.frame.size.height);
    
     */
    
    //[cell.icon setImage:[UIImage imageNamed:@"profile.png"]];
    cell.commentText.text = c.message;
    /*
    cell.icon.frame = CGRectMake(cell.icon.frame.origin.x, height / 2 - cell.icon.frame.size.height / 2, cell.icon.frame.size.width, cell.icon.frame.size.height);
    
    cell.commentText.lineBreakMode = NSLineBreakByWordWrapping;
    cell.commentText.numberOfLines = 0;
    [cell setClipsToBounds:NO];
    cell.commentText.layer.cornerRadius = 3.0f;
    cell.commentText.layer.masksToBounds = YES;
     */
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *msg = [comments[indexPath.row] message];
    return [self heightForText:msg] + 20.0;
}

-(CGFloat)heightForText:(NSString *)text
{
    NSInteger MAX_HEIGHT = 2000;
    UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, 250.0f, MAX_HEIGHT)];
    textView.text = text;
    textView.font = [UIFont fontWithName:@"Times New Roman" size:17];
    [textView sizeToFit];
    return textView.frame.size.height;
}

- (UIImage *)resizeImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) responseButtonClicked:(id)sender
{
    NSLog(@"Button clicked");
    NSString *myComment = self.responseTextInput.text;
    
    // SETUP PARAMETERS
    NSString *api_endpoint = @"/comments/";
    NSString *url = [api_url_base stringByAppendingString:api_endpoint];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithCapacity:10];
    [params setObject:self.user_id forKey:@"user_id"];
    [params setObject:myComment forKey:@"comment"];
    [params setObject:self.post.post_id forKey:@"post_id"];
    [manager.requestSerializer setValue:self.x_api_key forHTTPHeaderField:@"X-API-KEY"];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        //NSString *value = responseObject[@"type"];
        NSDictionary *dict = [responseObject objectAtIndex:0];
        NSString *type = dict[@"type"];
        
        if ([type isEqualToString:@"success"]) {
            NSLog(@"Successfully submitted the comment");
            
            self.responseTextInput.text = [COMMENT_PROMPT copy];
            Comment *newComment = [Comment new];
            newComment.user_id = self.user_id;
            newComment.message = myComment;
            
            //Remove the last object
            Comment *filler = comments[comments.count -1];
            [comments removeObjectAtIndex:(comments.count-1)];
            [comments addObject:newComment];
            [comments addObject:filler];
            
            [self.commentsTable reloadData];
            _backgroundScrollView.contentSize = CGSizeMake(self.view.frame.size.width, topImage.frame.size.height + _commentsTable.contentSize.height);
            CGPoint bottomOffset = CGPointMake(0, self.backgroundScrollView.contentSize.height - self.backgroundScrollView.bounds.size.height);
            [self.backgroundScrollView setContentOffset:bottomOffset animated:true];
            [self dismissKeyboard];
            
        }
        // If Unsuccessful, alert user
        else {
            // Check error code
            NSNumber *code = [dict[@"response"] valueForKey:@"code"];
            NSString *message = [dict[@"response"] valueForKey:@"message"];
            NSLog(@"There was an error: %@ with error message'%@'", code, message);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

-(void) checkIfPostFlagged {
    // AFNetworking API call to /posts/flagged
}

-(IBAction)flagPost:(id)sender {
    AMSmoothAlertView * alert;
    
    alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Post Reported!" andText:@"Thanks for sharing your voice." andCancelButton:NO forAlertType:AlertInfo];
    [alert.logoView setImage:[UIImage imageNamed:@"post_flag"]];
    alert.cornerRadius = 3.0f;
    [alert show];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}

// called right before the keyboard is shown
- (void)keyboardWillShow:(NSNotification*)notification
{
    NSLog(@"keyboard will shown!");
    
    if ([self.responseTextInput.text isEqualToString:[COMMENT_PROMPT copy]]) {
        self.responseTextInput.text = @"";
    }
    //self.responseTextInput.textColor = [UIColor blackColor];
    
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    self.responseView.frame = CGRectMake(self.responseView.frame.origin.x, self.view.frame.size.height - keyboardSize.height - self.responseView.frame.size.height, self.responseView.frame.size.width, self.responseView.frame.size.height);
    [UIView commitAnimations];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)notification
{
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    NSLog(@"Keyboard was hidden");
    
    if (self.responseTextInput.text.length == 0) {
        self.responseTextInput.text = [COMMENT_PROMPT copy];
        self.responseTextInput.textColor = [UIColor whiteColor];
    }
    
    [self responseViewHideCheck:self.backgroundScrollView keyboardJustHidden:true];
}

@end
