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

public class ListView implements FlutterPlugin, MethodChannel.MethodCallHandler  {
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "ListView");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("fetchMealData")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            String meal = call.argument("meal");
            fetchMealData(userId, date, meal, result);
        } else if(call.method.equals("fetchWorkoutData")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            fetchWorkoutData(userId, date, result);
        } else if(call.method.equals("fetchWaterData")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            fetchWaterData(userId, date, result);
        } else if(call.method.equals("fetchWeightData")) {
            String userId = call.argument("userId");
            fetchWeightData(userId, result);
        } else if(call.method.equals("fetchPresetData")) {
            String userId = call.argument("userId");
            fetchPresetData(userId, result);
        } else {
            result.notImplemented();
        }
    }

    public void fetchMealData(String userId, String date, String meal, Result result) {
        databaseRef.child("Meal").child(meal).child(userId)
                .child(date)
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(DataSnapshot dataSnapshot) {
                        List<Map<String, Object>> records = new ArrayList<>();

                        if (dataSnapshot.exists()) {
                            for (DataSnapshot mealSnapshot : dataSnapshot.getChildren()) {
                                String mealTitle = mealSnapshot.getKey();
                                String description = mealSnapshot.child("Description").getValue(String.class);
                                Double calory = mealSnapshot.child("Calory").getValue(Double.class);

                                if (mealTitle != null && description != null && calory != null) {
                                    // Create a map to hold meal details
                                    Map<String, Object> record = new HashMap<>();
                                    record.put("mealTitle", mealTitle);
                                    record.put("description", description);
                                    record.put("calory", calory);

                                    records.add(record);
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

    public void fetchWorkoutData(String userId, String date, Result result) {
        databaseRef.child("Workout").child(userId)
                .child(date)  // Ensure this date format matches your database
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(DataSnapshot dataSnapshot) {
                        List<Map<String, Object>> records = new ArrayList<>();

                        // Check if data exists at the specified location
                        if (dataSnapshot.exists()) {
                            // If data exists, iterate over child nodes (each meal record)
                            for (DataSnapshot workoutSnapshot : dataSnapshot.getChildren()) {
                                String workout = workoutSnapshot.getKey();  // Get meal title (key)
                                String duration = workoutSnapshot.child("Duration").getValue(String.class);  // Get description
                                Double calory = workoutSnapshot.child("Calory").getValue(Double.class);  // Get calorie value

                                // Create a new Meal object and add it to the list
                                if (workout != null && duration != null && calory != null) {
                                    Map<String, Object> record = new HashMap<>();
                                    record.put("mealTitle", workout);
                                    record.put("description", duration);
                                    record.put("calory", calory);

                                    records.add(record);
                                }
                            }
                        }
                        // After checking for data, always call the listener with the result
                        // Even if no records were found (empty list)
                        result.success(records); // Send the data back to Flutter
                    }

                    @Override
                    public void onCancelled(DatabaseError databaseError) {
                        result.error("DATABASE_ERROR", databaseError.getMessage(), null);
                    }
                });
    }
    public void fetchWaterData(String userId, String date, Result result) {
        databaseRef.child("Water").child(userId)
                .child(date)  // Ensure this date format matches your database
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(DataSnapshot dataSnapshot) {
                        List<Map<String, Object>> records = new ArrayList<>();

                        // Check if data exists at the specified location
                        if (dataSnapshot.exists()) {
                            // If data exists, iterate over child nodes (each meal record)
                            for (DataSnapshot waterSnapshot : dataSnapshot.getChildren()) {
                                String time = waterSnapshot.getKey();  // Get meal title (key)
                                Double amount = waterSnapshot.child("Amount").getValue(Double.class);  // Get calorie value

                                // Create a new Meal object and add it to the list
                                if (time != null && amount != null) {
                                    Map<String, Object> record = new HashMap<>();
                                    record.put("time", time);
                                    record.put("amount", amount);

                                    records.add(record);
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

    public void fetchWeightData(String userId, Result result) {
        databaseRef.child("Weight").child(userId).orderByKey().limitToLast(30)
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(DataSnapshot dataSnapshot) {
                        // Create a list to store fetched meal records
                        List<Map<String, Object>> records = new ArrayList<>();

                        // Check if data exists at the specified location
                        if (dataSnapshot.exists()) {
                            // If data exists, iterate over child nodes (each meal record)
                            for (DataSnapshot weightSnapshot : dataSnapshot.getChildren()) {
                                String date = weightSnapshot.getKey();  // Get meal title (key)
                                Double weight = weightSnapshot.getValue(Double.class);  // Get calorie value

                                // Create a new Meal object and add it to the list
                                if (date != null && weight != null) {
                                    Map<String, Object> record = new HashMap<>();
                                    record.put("date", date);
                                    record.put("weight", weight);

                                    records.add(record);
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
    public void fetchPresetData(String userId, Result result) {
        databaseRef.child("Preset").child(userId)
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(DataSnapshot dataSnapshot) {
                        // List to hold each meal's data as a map
                        List<Map<String, Object>> records = new ArrayList<>();

                        // Ensure that data exists for the given userId
                        if (dataSnapshot.exists()) {
                            // Iterate over each meal record (the key is the meal name)
                            for (DataSnapshot mealSnapshot : dataSnapshot.getChildren()) {
                                // Create a map to store details for this meal
                                Map<String, Object> mealData = new HashMap<>();

                                // Use the meal's key as its name
                                String mealName = mealSnapshot.getKey();
                                mealData.put("mealName", mealName);

                                // Iterate over the meal details
                                for (DataSnapshot detailSnapshot : mealSnapshot.getChildren()) {
                                    String key = detailSnapshot.getKey();
                                    Object value = detailSnapshot.getValue();

                                    // If the key is "Nutrients", handle it as a nested object
                                    if ("Nutrients".equals(key)) {
                                        Map<String, Object> nutrients = new HashMap<>();
                                        // Loop through each nutrient field
                                        for (DataSnapshot nutrientSnapshot : detailSnapshot.getChildren()) {
                                            nutrients.put(nutrientSnapshot.getKey(), nutrientSnapshot.getValue());
                                        }
                                        mealData.put("Nutrients", nutrients);
                                    } else {
                                        // Otherwise, simply add the key/value pair
                                        mealData.put(key, value);
                                    }
                                }
                                // Add this meal's map to the list of records
                                records.add(mealData);
                            }
                        }
                        // Send the list of meal records back to Flutter
                        result.success(records);
                    }

                    @Override
                    public void onCancelled(DatabaseError databaseError) {
                        result.error("DATABASE_ERROR", databaseError.getMessage(), null);
                    }
                });
    }
}
