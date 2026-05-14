package com.example.fyp.Admin;

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

public class AdFeedback implements FlutterPlugin, MethodChannel.MethodCallHandler  {
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "AdFeedback");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("fetchFeedback")){
            fetchFeedbackRecords(result);
        } else {
            result.notImplemented();
        }
    }

    public void fetchFeedbackRecords(MethodChannel.Result result) {
        databaseRef.child("Feedback").addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                List<Map<String, Object>> records = new ArrayList<>();

                for (DataSnapshot uidSnapshot : dataSnapshot.getChildren()) { // Iterate through each UID
                    for (DataSnapshot dateSnapshot : uidSnapshot.getChildren()) { // Iterate through each Date under the UID
                        String date = dateSnapshot.getKey(); // Extract the date

                        for (DataSnapshot feedbackSnapshot : dateSnapshot.getChildren()) { // Iterate through feedback records (auto-generated keys)
                            String title = feedbackSnapshot.child("Title").getValue(String.class);
                            String body = feedbackSnapshot.child("Body").getValue(String.class);

                            if (title != null && body != null) {
                                Map<String, Object> record = new HashMap<>();
                                record.put("date", date);
                                record.put("title", title);
                                record.put("body", body);

                                records.add(record);
                            }
                        }
                    }
                }
                result.success(records); // Send the data back to Flutter
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                result.error("DATABASE_ERROR", databaseError.getMessage(), null);
            }
        });
    }
}
