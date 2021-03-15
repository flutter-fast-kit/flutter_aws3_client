package exchange.spg.flutter.flutter_aws_s3_client

import android.content.Context
import android.net.Uri
import android.util.Log
import com.amazonaws.ClientConfiguration
import com.amazonaws.auth.AWSCredentialsProvider
import com.amazonaws.mobile.client.AWSMobileClient
import com.amazonaws.mobile.client.Callback
import com.amazonaws.mobile.client.UserStateDetails
import com.amazonaws.mobile.config.AWSConfiguration
import com.amazonaws.mobileconnectors.s3.transferutility.TransferObserver
import com.amazonaws.mobileconnectors.s3.transferutility.TransferUtility
import com.amazonaws.regions.Region
import com.amazonaws.services.s3.AmazonS3Client
import org.json.JSONException
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.*
import java.util.concurrent.CountDownLatch

/**
 * Handles basic helper functions used throughout the app.
 */
class Util {
    private var sS3Client: AmazonS3Client? = null
    private var sMobileClient: AWSCredentialsProvider? = null
    private var sTransferUtility: TransferUtility? = null

    /**
     * Gets an instance of AWSMobileClient which is
     * constructed using the given Context.
     *
     * @param context Android context
     * @return AWSMobileClient which is a credentials provider
     */
    private fun getCredProvider(context: Context): AWSCredentialsProvider? {
        if (sMobileClient == null) {
            val latch = CountDownLatch(1)
            AWSMobileClient.getInstance().initialize(context, object : Callback<UserStateDetails?> {
                override fun onResult(result: UserStateDetails?) {
                    latch.countDown()
                }

                override fun onError(e: Exception?) {
                    Log.e(TAG, "onError: ", e)
                    latch.countDown()
                }
            })
            try {
                latch.await()
                sMobileClient = AWSMobileClient.getInstance()
            } catch (e: InterruptedException) {
                e.printStackTrace()
            }
        }
        return sMobileClient
    }

    private fun getClientConfiguration(): ClientConfiguration {
        val clientConfiguration = ClientConfiguration()
        clientConfiguration.withMaxErrorRetry(0)
                .withConnectionTimeout(10000)
                .withSocketTimeout(10000)
        return clientConfiguration
    }

    /**
     * Gets an instance of a S3 client which is constructed using the given
     * Context.
     *
     * @param context Android context
     * @return A default S3 client.
     */
    private fun getS3Client(context: Context): AmazonS3Client? {
        if (sS3Client == null) {
            try {
                val regionString = AWSConfiguration(context)
                        .optJsonObject("S3TransferUtility")
                        .getString("Region")
                val region = Region.getRegion(regionString)
                val configuration = getClientConfiguration()
                configuration.connectionTimeout = 30 * 1000
                configuration.socketTimeout = 30 * 1000
                configuration.isEnableGzip = true
                configuration.maxConnections = 30
                configuration.maxErrorRetry = 2
                sS3Client = AmazonS3Client(getCredProvider(context), region, configuration)
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
        return sS3Client
    }

    /**
     * Gets an instance of the TransferUtility which is constructed using the
     * given Context
     *
     * @param context Android context
     * @return a TransferUtility instance
     */
    fun getTransferUtility(context: Context): TransferUtility? {
        if (sTransferUtility == null) {
            val awsConfiguration = AWSConfiguration(context)
            sTransferUtility = TransferUtility.builder()
                    .context(context)
                    .s3Client(getS3Client(context))
                    .awsConfiguration(awsConfiguration)
                    .build()
        }
        return sTransferUtility
    }

    /**
     * Converts number of bytes into proper scale.
     *
     * @param bytes number of bytes to be converted.
     * @return A string that represents the bytes in a proper scale.
     */
    private fun getBytesString(bytes: Long): String {
        val quantifiers = arrayOf(
                "KB", "MB", "GB", "TB"
        )
        var speedNum = bytes.toDouble()
        var i = 0
        while (true) {
            if (i >= quantifiers.size) {
                return ""
            }
            speedNum /= 1024.0
            if (speedNum < 512) {
                return String.format(Locale.US, "%.2f", speedNum) + " " + quantifiers[i]
            }
            i++
        }
    }

    /**
     * Copies the data from the passed in Uri, to a new file for use with the
     * Transfer Service
     *
     * @param context Android context
     * @param uri Content URI
     * @return New file copied from given URI
     * @throws IOException if data read/write fails
     */
    @Throws(IOException::class)
    fun copyContentUriToFile(context: Context, uri: Uri?): File {
        val `is` = context.contentResolver.openInputStream(uri!!)
        val copiedData = File(context.getDir("SampleImagesDir", Context.MODE_PRIVATE),
                UUID.randomUUID().toString())
        copiedData.createNewFile()
        val fos = FileOutputStream(copiedData)
        val buf = ByteArray(2046)
        var read = -1
        while (`is`!!.read(buf).also { read = it } != -1) {
            fos.write(buf, 0, read)
        }
        fos.flush()
        fos.close()
        return copiedData
    }

    /**
     * Fills in the map with information in the observer so that it can be used
     * with a SimpleAdapter to populate the UI
     */
    fun fillMap(map: MutableMap<String?, Any?>, observer: TransferObserver, isChecked: Boolean) {
        val progress = (observer.bytesTransferred.toDouble() * 100 / observer
                .bytesTotal).toInt()
        map["id"] = observer.id
        map["checked"] = isChecked
        map["fileName"] = observer.absoluteFilePath
        map["progress"] = progress
        map["bytes"] = (getBytesString(observer.bytesTransferred) + "/"
                + getBytesString(observer.bytesTotal))
        map["state"] = observer.state
        map["percentage"] = "$progress%"
    }

    companion object {
        private val TAG = Util::class.java.simpleName
    }
}