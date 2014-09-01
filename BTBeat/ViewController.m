//
//  ViewController.m
//  BTBeat
//
//  Created by Martin Wenisch on 08/07/14.
//  Copyright (c) 2014 September Projects s.r.o. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioServices.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)event1ButtonPressed:(id)sender
{
    [[BTBeat sharedInstance] addEvent:BTBEAT_EVENT_BT_AUTHORISATION_REQUEST_SENT];
}

- (void)event2ButtonPressed:(id)sender
{
    [[BTBeat sharedInstance] addEvent:BTBEAT_EVENT_NOTIFICATION_SENT];
}

- (void)event3ButtonPressed:(id)sender
{
    [[BTBeat sharedInstance] addEvent:BTBEAT_EVENT_NOTIFICATION_CONVERSION];
}

- (void)sendButtonPressed:(id)sender
{
    [[BTBeat sharedInstance] sendData];
}

@end
