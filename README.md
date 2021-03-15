# flutter_aws_s3_client

Amazon S3 plugin for Flutter.

## 开始使用

### 安装

```yaml
flutter_aws_s3_client:
    git:
      url: git@gitlab.tqxd.com:aitd_exchange/aitd_exchange_mobile/flutter/flutter_aws3_client.git
      ref: v1.0.0
```

### 配置iOS

#### 在工程目录的 **info.plist** 里添加aws3配置信息

```xml
<key>AWS</key>
<dict>
  <key>CredentialsProvider</key>
  <dict>
      <key>CognitoIdentity</key>
      <dict>
          <key>Default</key>
          <dict>
              <key>PoolId</key>
              <string>your PoolId</string>
              <key>Region</key>
              <string>your Region</string>
          </dict>
      </dict>
  </dict>
  <key>S3TransferUtility</key>
  <dict>
      <key>Default</key>
      <dict>
          <key>Region</key>
          <string>your aws3 Region</string>
      </dict>
  </dict>
</dict>
```

区域列表

```
AWSRegionUnknown
AWSRegionUSEast1
AWSRegionUSEast2
AWSRegionUSWest1
AWSRegionUSWest2
AWSRegionEUWest1
AWSRegionEUWest2
AWSRegionEUCentral1
AWSRegionAPSoutheast1
AWSRegionAPNortheast1
AWSRegionAPNortheast2
AWSRegionAPSoutheast2
AWSRegionAPSouth1
AWSRegionSAEast1
AWSRegionCNNorth1
AWSRegionCACentral1
AWSRegionUSGovWest1
AWSRegionCNNorthWest1
AWSRegionEUWest3
```

如果需要支持后台上传, 需要在 **Appdelegate** 里添加


objc:

```objc
- (void) application:(UIApplication *)application
   handleEventsForBackgroundURLSession:(NSString *)identifier
   completionHandler:(void (^)(void))completionHandler {

       //provide the completionHandler to the TransferUtility to support background transfers.
       [AWSS3TransferUtility interceptApplication:application
              handleEventsForBackgroundURLSession:identifier
                                completionHandler:completionHandler];
}
```

swift:

```swift
override func application(
    _ application: UIApplication,
    handleEventsForBackgroundURLSession identifier: String,
    completionHandler: @escaping () -> Void) {
        AWSS3TransferUtility 
            .interceptApplication(
                application,
                handleEventsForBackgroundURLSession: identifier,
                completionHandler: completionHandler)
}
```

### 配置 Android

在Android工程目录 `app/src/main/res/raw/` (raw可能需要手动创建), 创建文件 `awsconfiguration.json`

内容如下, 根据需要进行修改

```json
{
  "Version": "1.0",
  "IdentityManager": {
    "Default": {}
  },
  "CredentialsProvider": {
    "CognitoIdentity": {
      "Default": {
        "PoolId": "ap-southeast-1:494d093d-5d13-4f05-89ee-8d2343291335",
        "Region": "ap-southeast-1"
      }
    }
  },
  "S3TransferUtility": {
    "Default": {
      "Bucket": "new-aitd-image-public",
      "Region": "ap-southeast-1"
    }
  }
}
```

需要后台上传则需要添加：

`Application.kt`

```kotlin
override fun onCreate() {
    super.onCreate()
    val tsIntent = Intent(this, TransferService::class.java)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        tsIntent.putExtra(TransferService.INTENT_KEY_NOTIFICATION, notification)
        tsIntent.putExtra(TransferService.INTENT_KEY_NOTIFICATION_ID, 15)
        tsIntent.putExtra(TransferService.INTENT_KEY_REMOVE_NOTIFICATION, true)
        // Foreground service required starting from Android Oreo
        startForegroundService(tsIntent)
    } else {
        startService(tsIntent)
    }
}
```

`android/app/src/main/AndroidManifest.xml`

```xml
<service android:name="com.amazonaws.mobileconnectors.s3.transferutility.TransferService" android:enabled="true" />
```

### dart

```dart
import 'package:flutter_aws_s3_client/flutter_aws_s3_client.dart';
```

单文件上传

```dart
try {
  AwsS3UploadResult result = await FlutterAwsS3Client.upload(file);
} catch (AwsS3UploadException e) {
  print('上传失败！')
}
```

多文件上传

```dart
try {
  List<AwsS3UploadResult> result = await FlutterAwsS3Client.uploadFiles(files);
} catch (AwsS3UploadException e) {
  print('上传失败！')
}
```

AwsS3UploadFile

| 参数     | 描述              | 必须  | 默认值 |
| -------- | ----------------- | ----- | ------ |
| bucket   | 存储桶            | true  | Null   |
| identity | 文件key           | true  | Null   |
| filePath | 文件路径          | true  | Null   |
| options  | AwsS3RetryOptions | False |        |

AwsS3RetryOptions

| 参数                | 描述         | 必须  | 默认值                            |
| ------------------- | ------------ | ----- | --------------------------------- |
| delayFactor         |              | False | const Duration(milliseconds: 200) |
| randomizationFactor |              | False | 0.25                              |
| maxDelay            |              | False | const Duration(seconds: 30)       |
| maxAttempts         | 最大重试次数 | False | 3                                 |

AwsS3UploadResult

| 参数     | 描述       |
| -------- | ---------- |
| id       | 上传任务ID |
| identity | 文件key    |
| success  | 是否成功   |

## Changelog

Refer to the [Changelog](CHANGELOG.md) to get all release notes.

