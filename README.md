# LT SDK for iOS sample
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Swift-orange.svg)

[![cocoapods](https://img.shields.io/cocoapods/v/LTSDK)](https://github.com/LoFTechs/LTSDK-iOS)


## Introduction

With LT SDK, you can build your own customized application with instant messaging capabilities. This document provides a demonstration of the LTIMSDK method, showing how to implement the relevant operations.


## Getting started

This section explains the steps you need to take before testing the iOS LTIMSample app.


## Installation

To use our iOS sample, you should first install [LTIMSample for iOS](https://github.com/LoFTechs/LTIMSample-iOS-ObjectiveC) 1.0.0 or higher.
### Requirements

|Sample|iOS|
|---|---|
| LTIMSample |1.0.0 or higher|


### Install LT SDK for iOS

You can install LT SDK for iOS through `cocoapods`.

To install the pod, add following line to your Podfile:


```
pod 'LTSDK'
pod 'LTIMSDK'
``` 

Set Develop api data and password to `LTIMSample/Common/Resource/UserInfo.plist`.

```properties
LICENSEKEY="<YOUR_LINCENSE_KEY>"
USERID="<YOUR_USER_ID>"
UUID="<YOUR_UUID>"
URL="<YOUR_AUTH_API>"
``` 


## Use NotificationService

When your device is in the background, the system sends messages to your device through the Apple Push Notification Service (APNS). You can use the Notification Service extension to intercept and modify APNS payloads before they are presented to the user.

## FAQ: What should I do if I’m not receiving APNS?

If your iOS app is not receiving push notifications and you have confirmed that you have uploaded a token using the LTSDK, please refer to the following checklist to troubleshoot common misconfigurations and issues.

### 

 1. `Push Notifications` Capability Missing
- ✅ Fix: In **Signing & Capabilities**, add the **Push Notifications** capability.

 2. Ensure App is Not in Foreground (if using silent or background notifications)
- ✅ Some types of notifications do not appear if the app is in foreground unless explicitly handled.

 3. Ensure a Valid Device Token is Sent to Server
- 🚫 APNS Push is not supported on iOS simulators.
- ✅ Fix: Always test using a real device.
 
 3. Ensure User Has Granted Notification Permission on the Device
- ✅ On the iPhone, notifications must be enabled in Settings > [Your App] > Notifications. If the user denied permission, the app will not receive or display notifications. You can prompt again or guide the user to manually enable it in Settings.
 