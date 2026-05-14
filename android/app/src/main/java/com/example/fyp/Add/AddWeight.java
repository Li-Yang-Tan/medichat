package com.example.fyp.Add;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
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
public class AddWeight implements FlutterPlugin, MethodCallHandler{
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "AddWeight");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("AddWeight")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            double weight = call.argument("weight");
            addWeightData(userId, date, weight, result);
        } else if (call.method.equals("UpdateWeight")) {
            String userId = call.argument("userId");
            String date = call.argument("date");
            double weight = call.argument("weight");
            UpdateWeightData(userId, date, weight, result);
        } else {
            result.notImplemented();
        }
    }

    public void addWeightData(String userId, String date, double weight, Result result) {
        // Fetch the target calory amount first
        databaseRef.child("Weight").child(userId).child(date).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if (dataSnapshot.exists()) {
                    // Record exists, notify the listener
                    result.error("recorde", "Record already exist for this day.", null);
                } else {
                    // Record does not exist, proceed with adding the new record
                    Map<String, Object> update = new HashMap<>();
                    update.put(date, weight);

                    // Execute query to add the new record
                    databaseRef.child("Weight").child(userId).updateChildren(update).addOnCompleteListener(new OnCompleteListener<Void>() {
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
    public void UpdateWeightData(String userId, String date, double weight, Result result) {
        // Get the reference to the old record location (specific key under date)
        DatabaseReference oldRecordRef = databaseRef.child("Weight").child(userId).child(date);

        // Start by checking if the old record exists
        oldRecordRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.exists()) {
                    // Delete only the specific old record (not the entire date)
                    oldRecordRef.removeValue();

                    Map<String, Object> update = new HashMap<>();
                    update.put(date, weight);

                    // Execute query to add the new record
                    databaseRef.child("Weight").child(userId).updateChildren(update).addOnCompleteListener(new OnCompleteListener<Void>() {
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
                    result.error("recorde", "The record to edit does not exist.", null);
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
