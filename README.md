## Features
- Project detail: https://www.fromdingo.com/btbeat/
- Measure Bluetooth LE usage
- Anonnymously collect data and generate global Bluetooth usage statistics.

## Setup BTBeat
To add BTBeat to your application add **BTBeat.h** and **BTBeat.m** to your project and set *applicationName* property.


```
@property NSString *applicationName;
```

 Application identifier.

## Events
 
```
@property BOOL allowAutomaticEvents;
```

Automatically check if BlueTooth is turned on and off. Default value is **YES**.

```
 [[BTBeat sharedInstance] addEvent:@"Event name"];
```

 Predefined events:
 - *BTBEAT_EVENT_BT_UNSUPPORTED*
 - *BTBEAT_EVENT_BT_UNAUTHORISED*
 - *BTBEAT_EVENT_BT_AUTHORISATION_REQUEST_SENT*
 - *BTBEAT_EVENT_BT_AUTHORISED*
 - *BTBEAT_EVENT_BT_TURNED_ON*
 - *BTBEAT_EVENT_BT_TURNED_OFF*
 - *BTBEAT_EVENT_NOTIFICATION_SENT*
 - *BTBEAT_EVENT_NOTIFICATION_CONVERSION*

*BTBEAT_EVENT_BT_TURNED_ON*, *BTBEAT_EVENT_BT_TURNED_OFF*, *BTBEAT_EVENT_BT_UNSUPPORTED* and *BTBEAT_EVENT_BT_UNAUTHORISED*  are added automatically if *allowAutomaticEvents* is set to **YES**.

## Interaction with server

```
 @property BOOL sendDataAutomatically;
```

 Send data automatically once per hour. Default value is **YES**.

```
 [[BTBeat sharedInstance] sendData];
```

 Manually send collected data to server.

