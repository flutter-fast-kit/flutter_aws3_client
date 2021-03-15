import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_aws_s3_client/flutter_aws_s3_client.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  void _uploadFile(String filePath) async {
    try {
      List<AwsS3UploadResult> result = await FlutterAwsS3Client.uploadFiles([
        AwsS3UploadFile(
            bucket: 'new-aitd-image-public',
            identity: 'asdfasfsd324234324234.jpeg',
            filePath: filePath,
            options: AwsS3RetryOptions()),
        AwsS3UploadFile(
            bucket: 'new-aitd-image-public',
            identity: 'sdfasdfasdf.jpeg',
            filePath: filePath,
            options: AwsS3RetryOptions())
      ]);
      print('上传成功: ${result.toString()}');
    } catch (e) {
      print('文件上传失败: ');
    }
  }

  Future _chooseImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    _image = File(pickedFile.path);
    _uploadFile(_image.absolute.path);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: RaisedButton(
            child: Text('上传图片'),
            onPressed: _chooseImage,
          ),
        ),
      ),
    );
  }
}
