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

public class SetTarget implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "Target");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("fetchTargetData")) {
            String userId = call.argument("userId");
            fetchTargetData(userId, result);
        } else if (call.method.equals("editTargetData")){
            String userId = call.argument("userId");
            double weight = call.argument("weight");
            double water = call.argument("water");
            double calorie = call.argument("calorie");

            editTargetData(userId, weight, water, calorie, result);
        } else {
            result.notImplemented();
        }
    }

    private void fetchTargetData(String userId, MethodChannel.Result result) {
        databaseRef.child("User").child(userId).child("Target")
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                        double calorie = (dataSnapshot.child("Calorie").getValue(Double.class) == null)? 0.0 : dataSnapshot.child("Calorie").getValue(Double.class);
                        double water = (dataSnapshot.child("Water").getValue(Double.class) == null)? 0.0: dataSnapshot.child("Water").getValue(Double.class);
                        double weight = (dataSnapshot.child("Weight").getValue(Double.class) == null)? 0.0 : dataSnapshot.child("Weight").getValue(Double.class);

                        Map<String, Object> response = new HashMap<>();
                        response.put("calorie", calorie);
                        response.put("water", water);
                        response.put("weight", weight);

                        result.success(response);
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        result.error("DB_ERROR", error.getMessage(), null);
                    }
                });
    }

    private void editTargetData(String userId, double weight, double water, double calorie, MethodChannel.Result result) {
        Map<String, Object> updates = new HashMap<>();
        updates.put("Weight", weight);
        updates.put("Water", water);
        updates.put("Calorie", calorie);

        databaseRef.child("User").child(userId).child("Target").updateChildren(updates)
                .addOnSuccessListener(aVoid -> result.success("Data updated successfully"))
                .addOnFailureListener(e -> result.error("DB_ERROR", e.getMessage(), null));
    }
}
