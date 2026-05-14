package com.example.fyp;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
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

public class Feedback implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "Feedback");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("addFeedbackData")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            String title = call.argument("title");
            String body = call.argument("body");
            addFeedbackData(userId, date, title, body, result);
        } else {
            result.notImplemented();
        }
    }

    public void addFeedbackData(String userId, String date, String title, String body, MethodChannel.Result result) {
        databaseRef.child("Feedback").child(userId).child(date).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if (dataSnapshot.exists()) {

                    // Record exists, notify the listener
                    databaseRef.child("Feedback").child(userId).child(date).addListenerForSingleValueEvent(new ValueEventListener() {
                        @Override
                        public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                            Map<String, Object> feedbackData = new HashMap<>();
                            feedbackData.put("Title", title);
                            feedbackData.put("Body", body);

                            databaseRef.child("Feedback").child(userId).child(date).push().updateChildren(feedbackData).addOnCompleteListener(new OnCompleteListener<Void>() {
                                @Override
                                public void onComplete(@NonNull Task<Void> task) {
                                    if (task.isSuccessful()) {
                                        result.success("success");
                                    } else {
                                        result.error("recorde", "There's an issue when Submitting, please try again later.", null);
                                    }
                                }
                            });
                        }

                        @Override
                        public void onCancelled(@NonNull DatabaseError databaseError) {
                            // Handle potential errors
                            result.error("DB_ERROR", databaseError.getMessage(), null);
                        }
                    });
                } else {
                    // Create a map to store the feedback data
                    Map<String, Object> feedbackData = new HashMap<>();
                    feedbackData.put("Title", title);
                    feedbackData.put("Body", body);

                    Map<String, Object> feedbackData2 = new HashMap<>();
                    feedbackData2.put("First Feedback of the day", feedbackData );

                    Map<String, Object> feedbackData3 = new HashMap<>();
                    feedbackData3.put(date, feedbackData2 );

                    // Execute query to add the new record
                    databaseRef.child("Feedback").child(userId).updateChildren(feedbackData3).addOnCompleteListener(new OnCompleteListener<Void>() {
                        @Override
                        public void onComplete(@NonNull Task<Void> task) {
                            if (task.isSuccessful()) {
                                result.success(feedbackData);
                            } else {
                                result.error("recorde", "There's an issue when Submitting, please try again later.", null);
                            }
                        }
                    });
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {
                // Handle potential errors
                result.error("DB_ERROR", databaseError.getMessage(), null);
            }
        });
    }
}
