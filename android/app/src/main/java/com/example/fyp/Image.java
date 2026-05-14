package com.example.fyp;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

import androidx.annotation.NonNull;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class Image implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private MethodChannel channel;
    private static final String API_KEY = "";  // Replace with your OpenAI API key.

    @Override
    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "Image");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("AnalyzeImage")) {
            String imagePath = call.argument("imagePath");

            new Thread(() -> {
                try {
                    String response = analyzeImage(imagePath);
                    result.success(response);
                } catch (IOException e) {
                    e.printStackTrace();
                    result.error("IO_ERROR", e.getMessage(), null);
                }
            }).start();
        } else {
            result.notImplemented();
        }
    }

    private static String encodeImageToBase64(String imagePath) throws IOException {
        File imageFile = new File(imagePath);
        FileInputStream fis = new FileInputStream(imageFile);
        Bitmap bitmap = BitmapFactory.decodeStream(fis);
        fis.close();

        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 80, byteArrayOutputStream);
        byte[] imageBytes = byteArrayOutputStream.toByteArray();
        return Base64.encodeToString(imageBytes, Base64.NO_WRAP);
    }

    private static String analyzeImage(String imagePath) throws IOException {
        String base64Image = encodeImageToBase64(imagePath);

        String payload = "{ \"model\": \"gpt-4o-mini\", \"messages\": [ { \"role\": \"user\", \"content\": [ { \"type\": \"text\", \"text\": \"Provide the estimated amount of calories, carbs, protein, fat, saturated fat, fiber, sodium, sugar, cholesterol of the image in: xxx: xx.xxg format. No extra words.\" }, { \"type\": \"image_url\", \"image_url\": { \"url\": \"data:image/jpeg;base64," + base64Image + "\" } } ] } ] }";

        URL url = new URL("https://api.openai.com/v1/chat/completions");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setRequestProperty("Authorization", "Bearer " + API_KEY);
        connection.setDoOutput(true);

        try (OutputStream os = connection.getOutputStream()) {
            byte[] input = payload.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }

        StringBuilder response = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8))) {
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
        }

        return extractNutritionalData(response.toString());
    }

    private static String extractNutritionalData(String jsonResponse) {
        try {
            JSONObject responseObj = new JSONObject(jsonResponse);
            JSONArray choices = responseObj.optJSONArray("choices");

            if (choices != null && choices.length() > 0) {
                JSONObject firstChoice = choices.getJSONObject(0);
                JSONObject message = firstChoice.optJSONObject("message");

                if (message != null) {
                    return message.optString("content", "No nutritional data found.");
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return "Error parsing response.";
    }
}
