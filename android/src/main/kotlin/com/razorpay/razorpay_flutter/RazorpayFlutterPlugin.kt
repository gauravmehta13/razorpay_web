package com.razorpay.razorpay_flutter

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * RazorpayFlutterPlugin
 */
class RazorpayFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private var razorpayDelegate: RazorpayDelegate? = null
    private var pluginBinding: ActivityPluginBinding? = null

    companion object {
        private const val CHANNEL_NAME = "razorpay_flutter"
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }

    @Suppress("UNCHECKED_CAST")
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "open" -> {
                razorpayDelegate?.openCheckout(call.arguments as Map<String, Any>, result)
            }
            "setPackageName" -> {
                razorpayDelegate?.setPackageName(call.arguments as String)
            }
            "resync" -> {
                razorpayDelegate?.resync(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onAttachedToActivity(@NonNull binding: ActivityPluginBinding) {
        razorpayDelegate = RazorpayDelegate(binding.activity)
        pluginBinding = binding
        binding.addActivityResultListener(razorpayDelegate!!)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        pluginBinding?.removeActivityResultListener(razorpayDelegate!!)
        pluginBinding = null
    }
}
