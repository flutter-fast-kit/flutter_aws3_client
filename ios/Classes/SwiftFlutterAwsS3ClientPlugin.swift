import Flutter
import UIKit
import AWSS3
import AWSCore

public class SwiftFlutterAwsS3ClientPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_aws_s3_client", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterAwsS3ClientPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    var region1: AWSRegionType = AWSRegionType.USEast1
    var subRegion1: AWSRegionType = AWSRegionType.EUWest1

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method.elementsEqual("upload")) {
            let arguments = call.arguments as! NSDictionary
            let filePath = arguments["filePath"] as! String
            let bucket = arguments["bucket"] as! String
            let mimeType = arguments["mimeType"] as! String
            let identity = arguments["identity"] as! String
            
            upload(filePath: filePath, bucket: bucket, identity: identity, mimeType: mimeType, result: result)
        }
    }

    public func upload(filePath: String, bucket: String, identity: String, mimeType: String, result: @escaping FlutterResult) {

        let fileUrl = NSURL.fileURL(withPath: filePath)

        let expression = AWSS3TransferUtilityUploadExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        expression.progressBlock = {(task, progress) in
            print("task progress : \(task.transferID) -- \(progress.fractionCompleted)")
        }

        let S3TransferUtility = AWSS3TransferUtility.default()
        S3TransferUtility.uploadFile(fileUrl, bucket: bucket, key: identity, contentType: mimeType, expression: expression) { (task: AWSS3TransferUtilityTask, error) in
            let dic = NSMutableDictionary.init(capacity: 5)
            dic.setValue(task.transferID, forKey: "id")
            dic.setValue(identity, forKey: "identity")
            dic.setValue(error == nil, forKey: "success")
            result(dic);
        }
    }
}
