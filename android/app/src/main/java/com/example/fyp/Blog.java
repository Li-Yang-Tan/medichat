package com.example.fyp;

import androidx.annotation.NonNull;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class Blog implements FlutterPlugin, MethodChannel.MethodCallHandler{
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "Blog");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("FetchBlogData")) {
            fetchBlogRecords(result);
        } else {
            result.notImplemented();
        }
    }

    public void fetchBlogRecords(MethodChannel.Result result) {
        databaseRef.child("Blog").addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                // Create a list to store fetched meal records
                List<Map<String, Object>> records = new ArrayList<>();

                // Check if data exists at the specified location
                if (dataSnapshot.exists()) {
                    for (DataSnapshot dateSnapshot : dataSnapshot.getChildren()) {
                        String date = dateSnapshot.getKey();

                        for (DataSnapshot blogSnapshot : dateSnapshot.getChildren()) {
                            String title = blogSnapshot.getKey();
                            String description = blogSnapshot.child("Description").getValue(String.class);
                            String link = blogSnapshot.child("Link").getValue(String.class);

                            if (date != null && title != null && description != null && link != null) {
                                Map<String, Object> record = new HashMap<>();
                                record.put("date", date);
                                record.put("title", title);
                                record.put("description", description);
                                record.put("link", link);

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
