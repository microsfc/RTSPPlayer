//
//  DFUViewController.m
//  DFURTSPPlayer
//
//  Created by Bogdan Furdui on 3/7/13.
//  Copyright (c) 2013 Bogdan Furdui. All rights reserved.
//

#import "DFUViewController.h"
#import "RTSPPlayer.h"
#import "Utilities.h"

@interface DFUViewController ()
@property (nonatomic, retain) NSTimer *nextFrameTimer;
@end

@implementation DFUViewController

@synthesize imageView, label, playButton, video;
@synthesize nextFrameTimer = _nextFrameTimer;

//http://www.wowza.com/_h264/BigBuckBunny_115k.mov
//rtsp://media1.law.harvard.edu/Media/policy_a/2012/02/02_unger.mov
//rtsp://streaming.parliament.act.gov.au/medium
//@"rtsp://192.168.127.211:554/multicaststream_ch1_stream1"

NSString * const RTSPLINK = @"rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        video = [[RTSPPlayer alloc] initWithVideo:RTSPLINK usesTcp:NO];
        video.outputWidth = 1280;
        video.outputHeight = 720;

        NSLog(@"video duration: %f",video.duration);
        NSLog(@"video size: %d x %d", video.sourceWidth, video.sourceHeight);
    }
    
    return self;
}

- (void)dealloc
{
	[video release];
    video = nil;
    
	[imageView release];
    imageView = nil;
    
	[label release];
    label = nil;
    
	[playButton release];
    playButton = nil;

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self playButtonAction:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)playButtonAction:(id)sender {
	[playButton setEnabled:NO];
	lastFrameTime = -1;
	
	// seek to 0.0 seconds
	[video seekTime:0.0];
    
    [_nextFrameTimer invalidate];
	self.nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30
                                                           target:self
                                                         selector:@selector(displayNextFrame:)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (IBAction)showTime:(id)sender
{
    NSLog(@"current time: %f s", video.currentTime);
}

#define LERP(A,B,C) ((A)*(1.0-C)+(B)*C)

-(void)displayNextFrame:(NSTimer *)timer
{
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
	if (![video stepFrame]) {
		[timer invalidate];
		[playButton setEnabled:YES];
        [video closeAudio];
		return;
	}
	imageView.image = video.currentImage;
	float frameTime = 1.0/([NSDate timeIntervalSinceReferenceDate]-startTime);
	if (lastFrameTime<0) {
		lastFrameTime = frameTime;
	} else {
		lastFrameTime = LERP(frameTime, lastFrameTime, 0.8);
	}
	[label setText:[NSString stringWithFormat:@"%.0f",lastFrameTime]];
}

@end
