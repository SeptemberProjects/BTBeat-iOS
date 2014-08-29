//
//  BTBeat.m
//  BTBeat
//
//  Created by Martin Wenisch on 08/07/14.
//  Copyright (c) 2014 September Projects s.r.o. All rights reserved.
//

#import "BTBeat.h"

@interface BTBeat ()

@property (nonatomic, strong) CBCentralManager *centralBTManager;

@property (nonatomic, strong) NSMutableDictionary *localDataDictionary;
@property (nonatomic, strong) NSMutableDictionary *localStateDictionary;

@end

static BTBeat *sharedInstance;

@implementation BTBeat

+ (BTBeat *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BTBeat alloc] init];
        
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self loadFromLocalFile];
        
        if (self.localStateDictionary[@"initialDataGenerated"] == nil) {
            [self generateInitialData];
        }
        
        if (self.localDataDictionary[@"uuid"] == nil) {
            [self generateUUID];
        }
        
        if (self.localStateDictionary[@"allowAutomaticEvents"] == nil || [self.localStateDictionary[@"allowAutomaticEvents"] isEqualToString:@"YES"]) {
            self.allowAutomaticEvents = YES;
        } else {
            self.allowAutomaticEvents = NO;
        }
    }
    
    return self;
}

- (NSString *)protocolVersion
{
    return @"1.0.0";
}

- (void)generateUUID
{
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [self.localStateDictionary setValue:uuid forKey:@"uuid"];
}

- (void)generateInitialData
{
    NSString *locale = [self getLocale];
    NSString *deviceModel = [self getPhoneModel];
    
    [self.localDataDictionary setObject:@{@"model": deviceModel, @"locale": locale} forKey:@"initial-data"];
    
    [self.localStateDictionary setObject:@YES forKey:@"initialDataGenerated"];
}

- (void)sendData
{
    [self.localDataDictionary setObject:self.applicationName forKey:@"application"];
    [self.localDataDictionary setObject:[self protocolVersion] forKey:@"version"];
    [self.localDataDictionary setObject:self.localStateDictionary[@"uuid"] forKey:@"uuid"];
    
    NSData *serializedData = [NSJSONSerialization dataWithJSONObject:self.localDataDictionary options:0 error:nil];
    
    //send data
    [self sendDataWithJSON:serializedData];
}

- (void)addEvent:(NSString *)event
{
    NSMutableArray *events = self.localDataDictionary[@"events"];
    
    if (events == nil) {
        events = [[NSMutableArray alloc] init];
    }
    
    [events addObject:@{@"timestamp": [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], @"event": event}];
    
    [self.localDataDictionary setObject:events forKey:@"events"];
    
    if (self.sendDataAutomatically) {
        
    }
}

- (void)setAllowAutomaticEvents:(BOOL)allowAutomaticEvents
{
    _allowAutomaticEvents = allowAutomaticEvents;
    
    if (allowAutomaticEvents) {
        [self startBluetoothStatusMonitoring];
        
        [self.localStateDictionary setValue:@"YES" forKey:@"allowAutomaticEvents"];
    } else {
        if (self.centralBTManager != nil) {
            [self.centralBTManager stopScan];
        }
        
        [self.localStateDictionary setValue:@"NO" forKey:@"allowAutomaticEvents"];
    }
}

#pragma mark - Helper methods

- (NSString *)getPhoneModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (NSString *)getLocale
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (NSString *)getArchivePath
{
    NSString *documentDirectory = ((NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                          inDomains:NSUserDomainMask] lastObject]).path;
    
    return [documentDirectory stringByAppendingString:@"BTBeat_archive"];
}

- (NSString *)getStateArchivePath
{
    NSString *documentDirectory = ((NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                                    inDomains:NSUserDomainMask] lastObject]).path;
    
    return [documentDirectory stringByAppendingString:@"BTBeatState_archive"];
}

- (void)saveToLocalFile
{
    [NSKeyedArchiver archiveRootObject:self.localDataDictionary toFile:[self getArchivePath]];
    [NSKeyedArchiver archiveRootObject:self.localStateDictionary toFile:[self getStateArchivePath]];
}

- (void)loadFromLocalFile
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getArchivePath]]) {
        self.localDataDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getArchivePath]];
    } else {
        self.localDataDictionary = [[NSMutableDictionary alloc] init];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getStateArchivePath]]) {
        self.localStateDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getStateArchivePath]];
    } else {
        self.localStateDictionary = [[NSMutableDictionary alloc] init];
    }
    
}

#pragma mark - CBCentralManager delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"BT status: %ld", central.state);
    
    switch (central.state) {
        case CBCentralManagerStateUnsupported:
            [self addEvent:BTBEAT_EVENT_BT_UNSUPPORTED];
            break;
            
        case CBCentralManagerStateUnauthorized:
            [self addEvent:BTBEAT_EVENT_BT_UNAUTHORISED];
            break;
            
        case CBCentralManagerStatePoweredOff:
            [self addEvent:BTBEAT_EVENT_BT_TURNED_OFF];            
            break;
            
        case CBCentralManagerStatePoweredOn:
            [self addEvent:BTBEAT_EVENT_BT_TURNED_ON];
            break;
            
        default:
            break;
    }
}

- (void)startBluetoothStatusMonitoring {
    self.centralBTManager = [[CBCentralManager alloc]
                             initWithDelegate:self
                             queue:dispatch_get_main_queue()
                             options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
}

#pragma mark - networking

- (void)sendDataWithJSON:(NSData *)json
{
    NSString *urlString = [NSString stringWithFormat:@"%@data?user_uid=%@", BTBEAT_HOST, self.localStateDictionary[@"uuid"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = json;
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (error == nil) {
                                                        if ([response.MIMEType isEqualToString:@"application/json"]) {
                                                            if (data) {
                                                                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                
                                                                if ([jsonData[@"status"] isEqualToString:@"ok"]) {
                                                                    [self.localStateDictionary setValue:[NSDate date] forKey:@"last_send"];
                                                                    [self.localDataDictionary removeAllObjects];
                                                                    [self saveToLocalFile];
                                                                }
                                                            } else {
                                                                NSLog(@"Empty data");
                                                            }
                                                        } else {
                                                            NSLog(@"Wrong mime type");
                                                        }
                                                    } else {
                                                        NSLog(@"Error: %@", error);
                                                    }
                                                });
                                            }];
    [task resume];
    
    
}
 
 
@end
