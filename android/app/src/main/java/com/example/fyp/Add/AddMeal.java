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

public class AddMeal implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "AddMeal");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("AddMeal")) {
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
            addMealData(userId, date, meal, food, descr, calorie, carb,protein,fat,sfat,fiber,sugar,sodium,cholesterol, result);
        } else if (call.method.equals("UpdateMeal")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            String oldRecord = call.argument("oldRecord");
            String meal = call.argument("meal");
            String food = call.argument("food");
            String descr = call.argument("descr");
            double calorie = call.argument("calorie");
            double carb = call.argument("carb");
            double protein = call.argument("protein");
            double fat = call.argument("fat");
            double sfat = call.argument("sfat");
            double fiber = call.argument("fiber");
            double sugar = call.argument("sugar");
            double sodium = call.argument("sodium");
            double cholesterol = call.argument("cholesterol");
            updateDB(userId, date, oldRecord, meal, food, descr, calorie, carb,protein,fat,sfat,fiber,sugar,sodium,cholesterol, result);
        } else if (call.method.equals("Fetch")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            String meal = call.argument("meal");
            String food = call.argument("food");
            fetch(userId, meal, date, food, result);
        } else {
            result.notImplemented();
        }
    }

    public void addMealData(String userId, String date, String meal, String food, String descr, double calorie, double carbD, double proteinD, double fatD, double sfatD, double fiberD, double sugarD, double sodiumD, double cholesterolD, MethodChannel.Result result) {
        // Fetch the target calory amount first
        databaseRef.child("Meal").child(meal).child(userId).child(date).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if (dataSnapshot.exists()) {
                    // Record exists, notify the listener
                    databaseRef.child("Meal").child(meal).child(userId).child(date).child(food).addListenerForSingleValueEvent(new ValueEventListener() {
                        @Override
                        public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                            if (dataSnapshot.exists()) {
                                // Record exists, notify the listener
                                result.error("recorde", "Record already exist for this day.", null);
                            } else {
                                // Record does not exist, proceed with adding the new record
                                Map<String, Object> nutrient = new HashMap<>();
                                nutrient.put("Carbohydrate", carbD);
                                nutrient.put("Protein", proteinD);
                                nutrient.put("Fat", fatD);
                                nutrient.put("Saturated Fat", sfatD);
                                nutrient.put("Fiber", fiberD);
                                nutrient.put("Sugar", sugarD);
                                nutrient.put("Sodium", sodiumD);
                                nutrient.put("Cholesterol", cholesterolD);

                                Map<String, Object> update = new HashMap<>();
                                update.put("Calory", calorie);
                                update.put("Description", descr);
                                update.put("Nutrients", nutrient);

                                Map<String, Object> update2 = new HashMap<>();
                                update2.put(food, update);

                                // Execute query to add the new record
                                databaseRef.child("Meal").child(meal).child(userId).child(date).updateChildren(update2).addOnCompleteListener(new OnCompleteListener<Void>() {
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
                    Map<String, Object> nutrient = new HashMap<>();
                    nutrient.put("Carbohydrate", carbD);
                    nutrient.put("Protein", proteinD);
                    nutrient.put("Fat", fatD);
                    nutrient.put("Saturated Fat", sfatD);
                    nutrient.put("Fiber", fiberD);
                    nutrient.put("Sugar", sugarD);
                    nutrient.put("Sodium", sodiumD);
                    nutrient.put("Cholesterol", cholesterolD);

                    Map<String, Object> update = new HashMap<>();
                    update.put("Calory", calorie);
                    update.put("Description", descr);
                    update.put("Nutrients", nutrient);

                    Map<String, Object> update2 = new HashMap<>();
                    update2.put(food, update);

                    Map<String, Object> update3 = new HashMap<>();
                    update3.put(date, update2);

                    // Execute query to add the new record
                    databaseRef.child("Meal").child(meal).child(userId).updateChildren(update3).addOnCompleteListener(new OnCompleteListener<Void>() {
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

    public void updateDB(String userId, String date, String oldRecord, String meal, String food, String descr, double calorie, double carbD, double proteinD, double fatD, double sfatD, double fiberD, double sugarD, double sodiumD, double cholesterolD, MethodChannel.Result result) {
        // Get the reference to the old record location (specific key under date)
        DatabaseReference oldRecordRef = databaseRef.child("Meal").child(meal).child(userId).child(date).child(oldRecord);

        // Start by checking if the old record exists
        oldRecordRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.exists()) {
                    // Old record exists, proceed to overwrite it with new data

                    // Delete only the specific old record (not the entire date)
                    oldRecordRef.removeValue();

                    // Now add the new record under the new food key
                    Map<String, Object> nutrient = new HashMap<>();
                    nutrient.put("Carbohydrate", carbD);
                    nutrient.put("Protein", proteinD);
                    nutrient.put("Fat", fatD);
                    nutrient.put("Saturated Fat", sfatD);
                    nutrient.put("Fiber", fiberD);
                    nutrient.put("Sugar", sugarD);
                    nutrient.put("Sodium", sodiumD);
                    nutrient.put("Cholesterol", cholesterolD);

                    Map<String, Object> updatedRecord = new HashMap<>();
                    updatedRecord.put("Calory", calorie);
                    updatedRecord.put("Description", descr);
                    updatedRecord.put("Nutrients", nutrient);

                    // Create a new update map with the new food key
                    Map<String, Object> updateMap = new HashMap<>();
                    updateMap.put(food, updatedRecord);

                    // Perform the update: add the new record under the new food key
                    databaseRef.child("Meal").child(meal).child(userId).child(date).updateChildren(updateMap)
                            .addOnCompleteListener(new OnCompleteListener<Void>() {
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

    public void fetch(String userId, String meal, String date, String food, MethodChannel.Result result) {
        databaseRef.child("Meal").child(meal).child(userId).child(date).child(food).child("Nutrients")
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(DataSnapshot dataSnapshot) {
                        // Check if data exists at the specified location
                        if (dataSnapshot.exists()) {
                            double carb = 0.0, cholesterol = 0.0, fat = 0.0, fiber = 0.0, protein = 0.0, sat = 0.0, sodium = 0.0, sugar = 0.0;

                            carb = dataSnapshot.child("Carbohydrate").getValue(double.class);
                            cholesterol = dataSnapshot.child("Cholesterol").getValue(double.class);
                            fat = dataSnapshot.child("Fat").getValue(double.class);
                            fiber = dataSnapshot.child("Fiber").getValue(double.class);
                            protein = dataSnapshot.child("Protein").getValue(double.class);
                            sat = dataSnapshot.child("Saturated Fat").getValue(double.class);
                            sodium = dataSnapshot.child("Sodium").getValue(double.class);
                            sugar = dataSnapshot.child("Sugar").getValue(double.class);

                            Map<String, Object> response = new HashMap<>();
                            response.put("carb", carb);
                            response.put("protein", protein);
                            response.put("fat", fat);
                            response.put("saturated_fat", sat);
                            response.put("fiber", fiber);
                            response.put("sugar", sugar);
                            response.put("sodium", sodium);
                            response.put("cholesterol", cholesterol);

                            result.success(response);
                        }
                    }

                    @Override
                    public void onCancelled(DatabaseError databaseError) {
                        result.error("recorde", "There's an issue when fetching data, please try again later.", null);
                    }
                });
    }
}
