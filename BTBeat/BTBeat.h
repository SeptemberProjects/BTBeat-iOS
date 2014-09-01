//
//  BTBeat.h
//  BTBeat
//
//  Created by Martin Wenisch on 08/07/14.
//  Copyright (c) 2014 September Projects s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <sys/utsname.h>

#define BTBEAT_HOST @"https://fromdingo.com/btbeat/api/"
//#define BTBEAT_HOST @"http://localhost:3000/"

//list of fixed events events
#define BTBEAT_EVENT_BT_UNSUPPORTED @"BT_UNSUPPORTED"
#define BTBEAT_EVENT_BT_UNAUTHORISED @"BT_NOT_AUTH"
#define BTBEAT_EVENT_BT_AUTHORISATION_REQUEST_SENT @"BT_AUTH_SENT"
#define BTBEAT_EVENT_BT_AUTHORISED @"BT_AUTH"
#define BTBEAT_EVENT_BT_TURNED_ON @"BT_ON"
#define BTBEAT_EVENT_BT_TURNED_OFF @"BT_OFF"
#define BTBEAT_EVENT_NOTIFICATION_SENT @"NF_SENT"
#define BTBEAT_EVENT_NOTIFICATION_CONVERSION @"NF_CONV"

@interface BTBeat : NSObject <CBCentralManagerDelegate>

+ (BTBeat *)sharedInstance;

//application identifier
@property (nonatomic, strong) NSString *applicationName;

//allow automatic events
@property (nonatomic) BOOL allowAutomaticEvents;

//send data when application is closed
@property (nonatomic) BOOL sendDataAutomatically;

//version of BTBeat protocol, fixed number for build
- (NSString *)protocolVersion;

//generate initial data about phone
- (void)generateInitialData;


- (void)sendData;

//add event to measured data
- (void)addEvent:(NSString *)event;

@end
