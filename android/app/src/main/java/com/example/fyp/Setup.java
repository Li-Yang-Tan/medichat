package com.example.fyp;

import androidx.annotation.NonNull;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.HashMap;
import java.util.Map;

public class Setup implements FlutterPlugin, MethodCallHandler {
    private static final String CHANNEL_NAME = "Setup";
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        if (call.method.equals("addUser")) {
            try {
                int age = call.argument("age");
                String gender = call.argument("gender");
                double height = call.argument("height");
                double weight = call.argument("weight");

                FirebaseUser currentUser = FirebaseAuth.getInstance().getCurrentUser();
                if (currentUser == null) {
                    result.error("AUTH_ERROR", "User not logged in", null);
                    return;
                }

                DatabaseReference userRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference("User");
                String userId = currentUser.getUid();

                Map<String, Object> userData = new HashMap<>();
                userData.put("Age", age);
                userData.put("Sex", gender);
                userData.put("Height", height);
                userData.put("Weight", weight);
                userData.put("Role", "User");

                userRef.child(userId).setValue(userData)
                        .addOnCompleteListener(task -> {
                            if (task.isSuccessful()) {
                                result.success("User added successfully: " + userId);
                            } else {
                                result.error("DB_ERROR", "Failed to add user", null);
                            }
                        });

            } catch (Exception e) {
                result.error("EXCEPTION", e.getMessage(), null);
            }
        } else {
            result.notImplemented();
        }
    }
}