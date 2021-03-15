package exchange.spg.flutter.flutter_aws_s3_client

import android.R
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat.getSystemService
import androidx.core.content.ContextCompat.startForegroundService
import com.amazonaws.mobileconnectors.s3.transferutility.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File


/** FlutterAwsS3ClientPlugin */
class FlutterAwsS3ClientPlugin : FlutterPlugin, MethodCallHandler {

    private val LOGTAG = "Flutter-AWSS3"

    private lateinit var channel: MethodChannel
    private lateinit var transferUtility: TransferUtility
    private lateinit var context: Context
    private lateinit var util: Util

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_aws_s3_client")
        channel.setMethodCallHandler(this)
        this.context = flutterPluginBinding.applicationContext
        util = Util()
        transferUtility = util.getTransferUtility(context)!!
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "upload") {
            val filePath: String = call.argument("filePath")!!
            val bucket: String = call.argument("bucket")!!
            val identity: String = call.argument("identity")!!

            val file = File(filePath)
            val observer: TransferObserver = transferUtility.upload(bucket, identity, file)

            val map = mutableMapOf<String, Any>("identity" to identity)

            observer.setTransferListener(object : TransferListener {
                override fun onStateChanged(id: Int, state: TransferState) {
                    map["id"] = id.toString()
                    Log.d(LOGTAG, "状态改变: $state - fileKey: $identity")
                    if (state == TransferState.COMPLETED) {
                        map["success"] = true
                        result.success(map)
                    }
                }

                override fun onProgressChanged(id: Int, bytesCurrent: Long, bytesTotal: Long) {
                    Log.d(LOGTAG, "->>>> 进度: $bytesCurrent/$bytesTotal - fileKey: $identity")
                }

                override fun onError(id: Int, ex: Exception) {
                    Log.e(LOGTAG, "onError: id: $id")
                    Log.e(LOGTAG, Log.getStackTraceString(ex))
                    map["id"] = id.toString()
                    map["success"] = false
                    result.success(map)
                }
            })

        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
