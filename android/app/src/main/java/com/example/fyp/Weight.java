package com.example.fyp;

import androidx.annotation.NonNull;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

public class Weight implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "Weight");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("fetchWeightData")) {
            String userId = call.argument("userId");
            fetchWeightData(userId, result);
        } else if (call.method.equals("fetchTargetWeight")) {
            String userId = call.argument("userId");
            fetchTargetData(userId, result);
        } else {
            result.notImplemented();
        }
    }

    public void fetchWeightData(String userId, Result result) {
        databaseRef.child("Weight").child(userId).orderByKey().limitToLast(30)  // Fetch the last 30 records
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(DataSnapshot dataSnapshot) {
                        List<Double> data = new ArrayList<>();
                        List<String> dates = new ArrayList<>();

                        // Iterate through the children in the snapshot
                        for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
                            String date = snapshot.getKey();  // The date as the key
                            Double value = snapshot.getValue(Double.class);  // The weight value as Double

                            if (date != null && value != null) {
                                // Add data to the lists
                                dates.add(date);
                                data.add(value);
                            }
                        }

                        Map<String, Object> response = new HashMap<>();
                        response.put("dates", dates);
                        response.put("weights", data);

                        // Pass the data back to Flutter
                        result.success(response);
                    }

                    @Override
                    public void onCancelled(DatabaseError databaseError) {
                        result.error("DB_ERROR", databaseError.getMessage(), null);
                    }
                });
    }

    private void fetchTargetData(String userId, MethodChannel.Result result) {
        databaseRef.child("User").child(userId).child("Target")
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                        double weight = (dataSnapshot.child("Weight").getValue(Double.class) == null)? 0.0 : dataSnapshot.child("Weight").getValue(Double.class);

                        Map<String, Object> response = new HashMap<>();
                        response.put("weight", weight);

                        result.success(response);
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        result.error("DB_ERROR", error.getMessage(), null);
                    }
                });
    }
}
