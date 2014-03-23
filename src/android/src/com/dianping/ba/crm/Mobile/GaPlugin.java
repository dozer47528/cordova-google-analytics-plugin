package com.dianping.ba.crm.Mobile;

import com.google.analytics.tracking.android.*;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;


public class GaPlugin extends CordovaPlugin {
    GoogleAnalytics instance;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        instance = GoogleAnalytics.getInstance(cordova.getActivity());
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (instance == null) {
            callbackContext.error("plugin has not initialized");
            return true;
        }

        if (action.equals("initGA")) {
            initGa(args, callbackContext);
            return true;
        }
        if (action.equals("sendEvent")) {
            sendEvent(args, callbackContext);
        }
        if (action.equals("sendView")) {
            sendView(args, callbackContext);
        }
        if (action.equals("sendTiming")) {
            sendTiming(args, callbackContext);
        }
        if (action.equals("sendException")) {
            sendException(args, callbackContext);
        }
        if (action.equals("setCustomDimension")) {
            setCustomDimension(args, callbackContext);
        }
        if (action.equals("setCustomMetric")) {
            setCustomMetric(args, callbackContext);
        }
        return false;
    }

    private void initGa(JSONArray args, CallbackContext callback) {
        try {
            Tracker tracker = instance.getTracker(args.getString(0));
            instance.setDefaultTracker(tracker);

            Thread.UncaughtExceptionHandler myHandler = new CrashHandler();
            Thread.setDefaultUncaughtExceptionHandler(myHandler);

            callback.success("initGA - id = " + args.getString(0) + "; interval = " + args.getInt(1) + " seconds");
        } catch (Exception e) {
            callback.error(e.getMessage());
        }
    }

    private void sendEvent(JSONArray args, CallbackContext callback) {
        try {
            Tracker tracker = instance.getDefaultTracker();
            tracker.send(MapBuilder.createEvent(
                    args.getString(0),
                    args.getString(1),
                    args.getString(2),
                    args.getLong(3))
                    .build());

            callback.success("sendEvent - category = " + args.getString(0) + "; action = " + args.getString(1) + "; label = " + args.getString(2) + "; value = " + args.getInt(3));
        } catch (final Exception e) {
            callback.error(e.getMessage());
        }
    }

    private void sendView(JSONArray args, CallbackContext callback) {
        try {
            Tracker tracker = instance.getDefaultTracker();

            tracker.set(Fields.SCREEN_NAME, args.getString(0));

            tracker.send(MapBuilder
                    .createAppView()
                    .build()
            );

            callback.success("sendView - url = " + args.getString(0));
        } catch (final Exception e) {
            callback.error(e.getMessage());
        }
    }

    private void sendTiming(JSONArray args, CallbackContext callback) {
        try {
            Tracker tracker = instance.getDefaultTracker();
            tracker.send(MapBuilder.createTiming(
                    args.getString(0),
                    args.getLong(1),
                    args.getString(2),
                    args.getString(3)).build());
            callback.success("sendTiming passed - category = " + args.getString(0) + "; time = " + args.getInt(1) + "; name = " + args.getString(2) + "; label = " + args.getString(3));
        } catch (final Exception e) {
            callback.error(e.getMessage());
        }
    }

    private void sendException(JSONArray args, CallbackContext callback) {
        try {
            Tracker tracker = instance.getDefaultTracker();
            tracker.send(MapBuilder.createException(args.getString(0), args.getBoolean(1)).build());
            callback.success("sendException passed");
        } catch (final Exception e) {
            callback.error(e.getMessage());
        }
    }

    private void setCustomDimension(JSONArray args, CallbackContext callback) {
        try {
            Tracker tracker = instance.getDefaultTracker();
            tracker.set(Fields.customDimension(args.getInt(0)), args.getString(1));
            callback.success("setCustom passed - index = " + args.getInt(0) + "; value = " + args.getString(1));
        } catch (final Exception e) {
            callback.error(e.getMessage());
        }
    }

    private void setCustomMetric(JSONArray args, CallbackContext callback) {
        try {
            Tracker tracker = instance.getDefaultTracker();
            tracker.set(Fields.customMetric(args.getInt(0)), args.getString(1));
            callback.success("setCustom passed - index = " + args.getInt(0) + "; value = " + args.getString(1));
        } catch (final Exception e) {
            callback.error(e.getMessage());
        }
    }

    public class CrashHandler implements Thread.UncaughtExceptionHandler {
        @Override
        public void uncaughtException(Thread thread, Throwable throwable) {
            try {
                GoogleAnalytics ga = GoogleAnalytics.getInstance(cordova.getActivity());
                Tracker tracker = ga.getDefaultTracker();
                if (tracker != null) {
                    tracker.send(MapBuilder.createException(throwable.getMessage(), true).build());
                }
            } catch (Exception exp) {
                Log.e(exp);
            }
        }
    }
}