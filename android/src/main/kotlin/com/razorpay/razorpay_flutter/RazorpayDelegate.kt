package com.razorpay.razorpay_flutter

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.razorpay.Checkout
import com.razorpay.CheckoutActivity
import com.razorpay.ExternalWalletListener
import com.razorpay.PaymentData
import com.razorpay.PaymentResultWithDataListener
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import org.json.JSONException
import org.json.JSONObject

class RazorpayDelegate(private val activity: Activity) : 
    ActivityResultListener, 
    ExternalWalletListener, 
    PaymentResultWithDataListener {

    private var pendingResult: Result? = null
    private var pendingReply: Map<String, Any>? = null
    private var packageName: String? = null

    companion object {
        // Response codes for communicating with plugin
        private const val CODE_PAYMENT_SUCCESS = 0
        private const val CODE_PAYMENT_ERROR = 1
        private const val CODE_PAYMENT_EXTERNAL_WALLET = 2

        // Payment error codes for communicating with plugin
        private const val NETWORK_ERROR = 0
        private const val INVALID_OPTIONS = 1
        private const val PAYMENT_CANCELLED = 2
        private const val TLS_ERROR = 3
        private const val INCOMPATIBLE_PLUGIN = 3
        private const val UNKNOWN_ERROR = 100

        private fun translateRzpPaymentError(errorCode: Int): Int {
            return when (errorCode) {
                Checkout.NETWORK_ERROR -> NETWORK_ERROR
                Checkout.INVALID_OPTIONS -> INVALID_OPTIONS
                Checkout.PAYMENT_CANCELED -> PAYMENT_CANCELLED
                Checkout.TLS_ERROR -> TLS_ERROR
                Checkout.INCOMPATIBLE_PLUGIN -> INCOMPATIBLE_PLUGIN
                else -> UNKNOWN_ERROR
            }
        }
    }

    fun setPackageName(packageName: String) {
        this.packageName = packageName
    }

    fun openCheckout(arguments: Map<String, Any>, result: Result) {
        pendingResult = result

        val options = JSONObject(arguments)
        if (activity.packageName.equals(packageName, ignoreCase = true)) {
            val intent = Intent(activity, CheckoutActivity::class.java).apply {
                putExtra("OPTIONS", options.toString())
                putExtra("FRAMEWORK", "flutter")
            }
            activity.startActivityForResult(intent, Checkout.RZP_REQUEST_CODE)
        }
    }

    private fun sendReply(data: Map<String, Any>) {
        pendingResult?.let {
            it.success(data)
            pendingReply = null
        } ?: run {
            pendingReply = data
        }
    }

    fun resync(result: Result) {
        result.success(pendingReply)
        pendingReply = null
    }

    override fun onPaymentError(code: Int, message: String, paymentData: PaymentData) {
        val reply = HashMap<String, Any>()
        reply["type"] = CODE_PAYMENT_ERROR

        val data = HashMap<String, Any>()
        data["code"] = translateRzpPaymentError(code)

        try {
            val response = JSONObject(message)
            val errorObj = response.getJSONObject("error")
            data["message"] = errorObj.getString("description")

            val metadata = errorObj.getJSONObject("metadata")
            val metadataHash = HashMap<String, String>()
            val metaKeys = metadata.keys()
            while (metaKeys.hasNext()) {
                val key = metaKeys.next()
                metadataHash[key] = metadata.getString(key)
            }

            errorObj.remove("metadata")
            val resp = HashMap<String, Any>()
            val keys = errorObj.keys()
            while (keys.hasNext()) {
                val key = keys.next()
                resp[key] = errorObj.get(key)
            }

            resp["metadata"] = metadataHash
            resp["email"] = paymentData.userEmail
            resp["contact"] = paymentData.userContact
            data["responseBody"] = resp
        } catch (e: JSONException) {
            data["message"] = message
            data["responseBody"] = message
        }

        reply["data"] = data
        sendReply(reply)
    }

    override fun onPaymentSuccess(paymentId: String, paymentData: PaymentData) {
        val reply = HashMap<String, Any>()
        reply["type"] = CODE_PAYMENT_SUCCESS

        val data = HashMap<String, Any>()
        data["razorpay_payment_id"] = paymentData.paymentId
        data["razorpay_order_id"] = paymentData.orderId
        data["razorpay_signature"] = paymentData.signature

        if (paymentData.data.has("razorpay_subscription_id")) {
            try {
                data["razorpay_subscription_id"] = paymentData.data.optString("razorpay_subscription_id")
            } catch (e: Exception) {
                // Ignore exception
            }
        }

        reply["data"] = data
        sendReply(reply)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        try {
            val merchantActivityResult = Checkout::class.java.getMethod(
                "merchantActivityResult",
                Activity::class.java,
                Int::class.javaPrimitiveType,
                Int::class.javaPrimitiveType,
                Intent::class.java,
                PaymentResultWithDataListener::class.java,
                ExternalWalletListener::class.java
            )
            merchantActivityResult.invoke(null, activity, requestCode, resultCode, data, this, this)
        } catch (e: Exception) {
            Checkout.handleActivityResult(activity, requestCode, resultCode, data, this, this)
        }
        return true
    }

    override fun onExternalWalletSelected(walletName: String, paymentData: PaymentData) {
        val reply = HashMap<String, Any>()
        reply["type"] = CODE_PAYMENT_EXTERNAL_WALLET

        val data = HashMap<String, Any>()
        data["external_wallet"] = walletName
        reply["data"] = data

        sendReply(reply)
    }
}
