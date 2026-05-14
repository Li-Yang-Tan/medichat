package com.example.fyp;

import androidx.annotation.NonNull;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class Water implements FlutterPlugin, MethodCallHandler {
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "Water");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        if (call.method.equals("fetchWaterData")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            fetchWaterData(userId, date, result);
        } else {
            result.notImplemented();
        }
    }

    private void fetchWaterData(String userId, String date, Result result) {
        databaseRef.child("User").child(userId).child("Target").child("Water")
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        Integer targetAmount = snapshot.getValue(Integer.class);
                        if (targetAmount != null) {
                            fetchWaterConsumption(userId, date, targetAmount, result);
                        } else {
                            result.error("DATA_NOT_FOUND", "Target water amount not found", null);
                        }
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        result.error("DB_ERROR", error.getMessage(), null);
                    }
                });
    }

    private void fetchWaterConsumption(String userId, String date, int target, Result result) {
        databaseRef.child("Water").child(userId).child(date)
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        int totalAmount = 0;
                        for (DataSnapshot timeSnapshot : snapshot.getChildren()) {
                            Double amount = timeSnapshot.child("Amount").getValue(Double.class);
                            if (amount != null) {
                                totalAmount += amount;
                            }
                        }

                        // Return a Map with the target and consumed amounts
                        Map<String, Object> response = new HashMap<>();
                        response.put("target", target);
                        response.put("consumed", totalAmount);

                        result.success(response);
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        result.error("DB_ERROR", error.getMessage(), null);
                    }
                });
    }

}

