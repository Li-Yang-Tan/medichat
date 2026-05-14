package com.example.fyp.Add;

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

public class AddPreset implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "AddPreset");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("AddPreset")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            String meal = call.argument("meal");
            String food = call.argument("food");
            String descr = call.argument("descr");
            double calorie = call.argument("calorie");
            Double carb = call.argument("carb");
            Double protein = call.argument("protein");
            Double fat = call.argument("fat");
            Double sfat = call.argument("sfat");
            Double fiber = call.argument("fiber");
            Double sugar = call.argument("sugar");
            Double sodium = call.argument("sodium");
            Double cholesterol = call.argument("cholesterol");
            addPresetData(userId, date, meal, food, descr, calorie, carb,protein,fat,sfat,fiber,sugar,sodium,cholesterol, result);
        } else {
            result.notImplemented();
        }
    }

    public void addPresetData(String userId, String date, String meal, String food, String descr,
                              double calorie, double carbD, double proteinD, double fatD,
                              double sfatD, double fiberD, double sugarD, double sodiumD,
                              double cholesterolD, MethodChannel.Result result) {

        DatabaseReference mealRef = databaseRef.child("Preset").child(userId).child(food);

        // Check if the meal already exists
        mealRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                boolean mealExists = false;

                for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
                    if (snapshot.child("Meal").getValue(String.class).equals(meal)) {
                        mealExists = true;
                        break;
                    }
                }

                if (mealExists) {
                    // Meal with the same name exists, return error
                    result.error("recorde", "There's already a preset meal with this name.", null);
                } else {
                    // Prepare meal data
                    Map<String, Object> mealData = new HashMap<>();
                    mealData.put("Description", descr);
                    mealData.put("Calorie", calorie);
                    mealData.put("Meal", meal);  // Breakfast, Lunch, etc.

                    // Create a map for nutrients
                    Map<String, Object> nutrients = new HashMap<>();
                    nutrients.put("Carbohydrate", carbD);
                    nutrients.put("Protein", proteinD);
                    nutrients.put("Fat", fatD);
                    nutrients.put("Saturated Fat", sfatD);
                    nutrients.put("Fiber", fiberD);
                    nutrients.put("Sugar", sugarD);
                    nutrients.put("Sodium", sodiumD);
                    nutrients.put("Cholesterol", cholesterolD);

                    // Attach nutrients to meal data
                    mealData.put("Nutrients", nutrients);

                    // Save data into Firebase
                    mealRef.setValue(mealData).addOnCompleteListener(task -> {
                        if (task.isSuccessful()) {
                            result.success("Record Added Successfully.");
                        } else {
                            result.error("recorde", "There's an issue when adding, please try again later.", null);
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
}
