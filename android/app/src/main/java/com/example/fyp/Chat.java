package com.example.fyp;

import androidx.annotation.NonNull;
import com.example.fyp.Callback;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonElement;
import java.io.IOException;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class Chat implements FlutterPlugin, MethodCallHandler{
    private OkHttpClient client;
    private MethodChannel channel;

    public Chat() {
        client = new OkHttpClient();
    }

    public void sendMessageToOpenAI(String message, Callback callback) {
        JsonObject json = new JsonObject();
        JsonArray messagesArray = new JsonArray();

        JsonObject userMessage = new JsonObject();
        userMessage.addProperty("role", "user");
        userMessage.addProperty("content", message);
        messagesArray.add(userMessage);

        json.addProperty("model", "gpt-3.5-turbo");
        json.add("messages", messagesArray);

        RequestBody body = RequestBody.create(
                MediaType.get("application/json; charset=utf-8"),
                json.toString()
        );

        Request request = new Request.Builder()
                .url("https://api.openai.com/v1/chat/completions")
                .header("Authorization", "Bearer apikey")//replace with your OpenAI API key
                .post(body)
                .build();

        client.newCall(request).enqueue(new okhttp3.Callback() {
            @Override
            public void onFailure(@NonNull okhttp3.Call call, @NonNull IOException e) {
                callback.onFailure(e.getMessage());
            }

            @Override
            public void onResponse(@NonNull okhttp3.Call call, @NonNull okhttp3.Response response) throws IOException {
                if (response.isSuccessful()) {
                    String responseBody = response.body().string();
                    String aiMessage = parseResponse(responseBody);
                    callback.onSuccess(aiMessage);
                } else {
                    callback.onFailure("Failed to fetch response");
                }
            }
        });
    }

    private String parseResponse(String response) {
        JsonObject json = new Gson().fromJson(response, JsonObject.class);
        JsonArray choices = json.getAsJsonArray("choices");

        if (choices != null && choices.size() > 0) {
            JsonObject choice = choices.get(0).getAsJsonObject();
            JsonObject message = choice.getAsJsonObject("message");
            if (message != null) {
                JsonElement content = message.get("content");
                if (content != null) {
                    return content.getAsString();
                }
            }
        }
        return "Error: Invalid response format";
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        if (call.method.equals("sendMessageToOpenAI")) {
            String message = call.argument("message");
            sendMessageToOpenAI(message, new Callback() {
                @Override
                public void onSuccess(String aiMessage) {
                    result.success(aiMessage);
                }

                @Override
                public void onFailure(String errorMessage) {
                    result.error("ERROR", errorMessage, null);
                }
            });
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "chat");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
