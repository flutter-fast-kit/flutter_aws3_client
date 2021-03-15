import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:retry/retry.dart';

class FlutterAwsS3Client {
  static const MethodChannel _channel =
      const MethodChannel('flutter_aws_s3_client');

  /// 上传文件
  static Future<AwsS3UploadResult> upload(AwsS3UploadFile file) async {
    final r = RetryOptions(
        delayFactor: file.options?.delayFactor,
        maxDelay: file.options?.maxDelay,
        maxAttempts: file.options?.maxAttempts,
        randomizationFactor: file.options?.randomizationFactor);

    final response = await r.retry(
      () async => await _upload(file),
      retryIf: (e) {
        return e is AwsS3UploadException;
      },
    );

    return response;
  }

  /// 上传文件
  ///
  /// [file] 文件对象 [AwsS3UploadFile]
  static Future<AwsS3UploadResult> _upload(AwsS3UploadFile file) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'filePath': file.filePath,
      'bucket': file.bucket,
      'identity': file.identity,
    };

    String mimeType = lookupMimeType(file.filePath) ?? 'application/*';
    params['mimeType'] = mimeType;

    final result = await _channel.invokeMethod('upload', params);
    AwsS3UploadResult s3uploadResult = AwsS3UploadResult.fromJson(result);
    if (!s3uploadResult.success) {
      throw AwsS3UploadException(s3uploadResult);
    }

    return s3uploadResult;
  }

  /// 批量上传文件
  ///
  /// [files] 文件对象 [AwsS3UploadFile]
  static Future<List<AwsS3UploadResult>> uploadFiles(
      List<AwsS3UploadFile> files) {
    return Future.wait(files.map((f) => upload(f)).toList());
  }
}

class AwsS3UploadFile {
  /// 存储桶
  final String bucket;

  /// 文件key
  final String identity;

  /// 文件路径
  final String filePath;

  /// 重试
  final AwsS3RetryOptions options;

  const AwsS3UploadFile(
      {@required this.bucket,
      @required this.identity,
      @required this.filePath,
      this.options});
}

class AwsS3UploadResult {
  AwsS3UploadResult({
    this.id,
    this.identity,
    this.success = false,
  });

  String id;
  String identity;
  bool success;

  factory AwsS3UploadResult.fromJson(Map<dynamic, dynamic> json) =>
      AwsS3UploadResult(
        id: json['id'],
        identity: json['identity'],
        success: json['success'],
      );

  @override
  String toString() {
    return 'AwsS3UploadResult{id: $id, identity: $identity, success: $success}';
  }
}

class AwsS3UploadException implements Exception {
  AwsS3UploadResult data;

  AwsS3UploadException([this.data]);
}

class AwsS3RetryOptions {
  final Duration delayFactor;
  final double randomizationFactor;
  final Duration maxDelay;
  final int maxAttempts;

  const AwsS3RetryOptions({
    this.delayFactor = const Duration(milliseconds: 200),
    this.randomizationFactor = 0.25,
    this.maxDelay = const Duration(seconds: 30),
    this.maxAttempts = 3,
  });
}
