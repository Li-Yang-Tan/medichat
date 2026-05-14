package com.example.fyp;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
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
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class Calory implements FlutterPlugin, MethodCallHandler {
    private DatabaseReference databaseRef;
    private MethodChannel channel;
    private int totalCalory;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "Calorie");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("fetchCalorieData")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            fetchCalorieData(userId, date, result);
        } else {
            result.notImplemented();
        }
    }

    public void fetchCalorieData(String userId, String date, Result result) {
        // Fetch the target calory amount first
        databaseRef.child("User").child(userId).child("Target").addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                Integer targetAmount = dataSnapshot.child("Calorie").getValue(Integer.class);
                if (targetAmount != null) {
                    // Fetch calorie intake for each meal after getting the target amount
                    fetchMealCalories(userId, date, targetAmount, result);
                } else {
                    result.error("DATA_NOT_FOUND", "Target calorie amount not found", null);
                }
            }

            @Override
            public void onCancelled(DatabaseError error) {
                result.error("DB_ERROR", error.getMessage(), null);
            }
        });
    }

    private void fetchMealCalories(String UID, String date, int targetAmount, Result result) {
        totalCalory = 0; // Initialize total calorie sum

        // Create a list of tasks for the three meals
        List<Task<Void>> tasks = new ArrayList<>();

        // Add a task for each meal to the list
        tasks.add(fetchCaloriesForMeal("Breakfast", UID, date));
        tasks.add(fetchCaloriesForMeal("Lunch", UID, date));
        tasks.add(fetchCaloriesForMeal("Dinner", UID, date));

        // Wait for all tasks to complete
        Tasks.whenAllSuccess(tasks).addOnSuccessListener(aVoid -> {
            // Return a Map with the target and consumed amounts
            Map<String, Object> response = new HashMap<>();
            response.put("target", targetAmount);
            response.put("consumed", totalCalory);

            result.success(response);
        }).addOnFailureListener(e -> {
            result.error("DB_ERROR", e.getMessage(), null);
        });
    }

    private Task<Void> fetchCaloriesForMeal(String mealType, String UID, String date) {
        // Create a Task that performs the fetching of calories for a single meal
        TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

        databaseRef.child("Meal").child(mealType).child(UID).child(date)
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(DataSnapshot dataSnapshot) {
                        if (dataSnapshot.exists()) {
                            for (DataSnapshot mealSnapshot : dataSnapshot.getChildren()) {
                                Double calory = mealSnapshot.child("Calory").getValue(Double.class);
                                if (calory != null) {
                                    totalCalory += calory; // Add each meal's calorie to the total
                                }
                            }
                        }
                        taskCompletionSource.setResult(null); // Task completed successfully
                    }

                    @Override
                    public void onCancelled(DatabaseError databaseError) {
                        taskCompletionSource.setException(new Exception(databaseError.getMessage())); // Set error if cancelled
                    }
                });

        return taskCompletionSource.getTask();
    }
}
