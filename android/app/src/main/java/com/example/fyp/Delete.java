package com.example.fyp;

import androidx.annotation.NonNull;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class Delete implements FlutterPlugin, MethodChannel.MethodCallHandler{
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "Delete");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("Delete")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            String indicator = call.argument("indicator");
            String title = call.argument("title");
            delete(indicator, userId, date, title, result);
        } else {
            result.notImplemented();
        }
    }

    public void delete(String indicator, String userId, String date, String title,  MethodChannel.Result result) {
        DatabaseReference recordRef;

        // Construct the path based on the type
        if (indicator.equals("Workout")) {
            recordRef = databaseRef
                    .child("Workout")
                    .child(userId)
                    .child(date)
                    .child(title);

        } else if (indicator.equals("Water")) {
            recordRef = databaseRef
                    .child("Water")
                    .child(userId)
                    .child(date)
                    .child(title);

        } else if (indicator.equals("Preset")) {
            recordRef = databaseRef
                    .child("Preset")
                    .child(userId)
                    .child(title);

        } else if (indicator.equals("Weight")) {
            recordRef = databaseRef
                    .child("Weight")
                    .child(userId)
                    .child(date);

        }else {
            recordRef = databaseRef
                    .child("Meal")
                    .child(indicator)  // recycleD is part of the path inside "Meal"
                    .child(userId)
                    .child(date)
                    .child(title);
        }

        // Check if the record exists
        recordRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if (dataSnapshot.exists()) {
                    // Delete the specific record
                    recordRef.removeValue().addOnCompleteListener(task -> {
                        if (task.isSuccessful()) {
                            result.success("Record Added Successful.");
                        } else {
                            result.error("recorde", "There's an issue when deleting, please try again later.", null);
                        }
                    });
                } else {
                    result.error("recorde", "The record to be deleted does not exist.", null);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                result.error("recorde", "Error while checking the existing record.", null);
            }
        });
    }
}
