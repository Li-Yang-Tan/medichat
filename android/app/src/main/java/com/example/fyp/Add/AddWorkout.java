package com.example.fyp.Add;

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

public class AddWorkout implements FlutterPlugin, MethodChannel.MethodCallHandler  {
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "AddWorkout");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("AddWorkout")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            String workout = call.argument("workout");
            String duration = call.argument("duration");
            double calorie = call.argument("calorie");
            addWorkoutData(userId, date, workout, duration, calorie, result);
        } else if (call.method.equals("UpdateWorkout")){
            String userId = call.argument("userId");
            String date = call.argument("date");
            String oldRecord = call.argument("oldRecord");
            String workout = call.argument("workout");
            String duration = call.argument("duration");
            double calorie = call.argument("calorie");
            UpdateWorkoutData(userId, date, oldRecord, workout, duration, calorie, result);
        }else {
            result.notImplemented();
        }
    }

    public void addWorkoutData(String userId, String date, String workout, String duration,  double calorie, MethodChannel.Result result) {
        // Fetch the target calory amount first
        databaseRef.child("Workout").child(userId).child(date).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if (dataSnapshot.exists()) {
                    // Record exists, notify the listener
                    databaseRef.child("Workout").child(userId).child(date).child(workout).addListenerForSingleValueEvent(new ValueEventListener() {
                        @Override
                        public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                            if (dataSnapshot.exists()) {
                                // Record exists, notify the listener
                                result.error("recorde", "Record already exist for this day.", null);
                            } else {
                                // Record does not exist, proceed with adding the new record
                                Map<String, Object> update = new HashMap<>();
                                update.put("Calory", calorie);
                                update.put("Duration", duration);

                                Map<String, Object> update2 = new HashMap<>();
                                update2.put(workout, update);

                                // Execute query to add the new record
                                databaseRef.child("Workout").child(userId).child(date).updateChildren(update2).addOnCompleteListener(new OnCompleteListener<Void>() {
                                    @Override
                                    public void onComplete(@NonNull Task<Void> task) {
                                        if (task.isSuccessful()) {
                                            result.success("Record Added Successful.");
                                        } else {
                                            result.error("recorde", "There's an issue when adding, please try again later.", null);
                                        }
                                    }
                                });
                            }
                        }

                        @Override
                        public void onCancelled(@NonNull DatabaseError databaseError) {
                            // Handle potential errors
                            result.error("recorde", "Error while checking the existing record.", null);
                        }
                    });
                } else {
                    // Record does not exist, proceed with adding the new record
                    Map<String, Object> update = new HashMap<>();
                    update.put("Calory", calorie);
                    update.put("Duration", duration);

                    Map<String, Object> update2 = new HashMap<>();
                    update2.put(workout, update);

                    Map<String, Object> update3 = new HashMap<>();
                    update3.put(date, update2);

                    // Execute query to add the new record
                    databaseRef.child("Workout").child(userId).updateChildren(update3).addOnCompleteListener(new OnCompleteListener<Void>() {
                        @Override
                        public void onComplete(@NonNull Task<Void> task) {
                            if (task.isSuccessful()) {
                                result.success("Record Added Successful.");
                            } else {
                                result.error("recorde", "There's an issue when adding, please try again later.", null);
                            }
                        }
                    });
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {
                // Handle potential errors
                result.error("recorde", "Error while checking the existing record.", null);
            }
        });
    }

    public void UpdateWorkoutData(String userId, String date, String oldRecord, String workout, String duration,  double calorie, MethodChannel.Result result) {
        // Get the reference to the old record location (specific key under date)
        DatabaseReference oldRecordRef = databaseRef.child("Workout").child(userId).child(date).child(oldRecord);

        // Start by checking if the old record exists
        oldRecordRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.exists()) {
                    // Delete only the specific old record (not the entire date)
                    oldRecordRef.removeValue();

                    Map<String, Object> update = new HashMap<>();
                    update.put("Calory", calorie);
                    update.put("Duration", duration);

                    Map<String, Object> update2 = new HashMap<>();
                    update2.put(workout, update);

                    // Execute query to add the new record
                    databaseRef.child("Workout").child(userId).child(date).updateChildren(update2).addOnCompleteListener(new OnCompleteListener<Void>() {
                        @Override
                        public void onComplete(@NonNull Task<Void> task) {
                            if (task.isSuccessful()) {
                                result.success("Record Added Successful.");
                            } else {
                                result.error("recorde", "There's an issue when adding, please try again later.", null);
                            }
                        }
                    });
                } else {
                    // If the old record does not exist, notify the listener
                    result.error("recorde", "There's no existing record to update", null);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                // Handle potential errors
                result.error("recorde", "Error while checking the existing record.", null);
            }
        });
    }
}
