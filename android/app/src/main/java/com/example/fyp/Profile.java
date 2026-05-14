package com.example.fyp;

import androidx.annotation.NonNull;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
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
public class Profile implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "Profile");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("fetchProfileData")) {
            String userId = call.argument("userId");
            fetchProfileData(userId, result);
        } else if (call.method.equals("fetchUserData")) {
            String userId = call.argument("userId");
            fetchUserData(result);
        } else if (call.method.equals("editProfileData")){
            String userId = call.argument("userId");
            String name = call.argument("name");
            double weight = call.argument("weight");
            double height = call.argument("height");
            int age = call.argument("age");

            editProfileData(userId, name, weight, height, age, result);
        } else {
            result.notImplemented();
        }
    }

    private void fetchProfileData(String userId, MethodChannel.Result result) {
        databaseRef.child("User").child(userId)
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                        String name = (dataSnapshot.child("Username").getValue(String.class) == null)? "" : dataSnapshot.child("Username").getValue(String.class);
                        double weight = (dataSnapshot.child("Weight").getValue(Double.class) == null)? 0.0 : dataSnapshot.child("Weight").getValue(Double.class);
                        double height = (dataSnapshot.child("Height").getValue(Double.class) == null)? 0.0: dataSnapshot.child("Height").getValue(Double.class);
                        int age = (dataSnapshot.child("Age").getValue(Integer.class) == null)? 0 : dataSnapshot.child("Age").getValue(Integer.class);

                        Map<String, Object> response = new HashMap<>();
                        response.put("name", name);
                        response.put("weight", weight);
                        response.put("height", height);
                        response.put("age", age);

                        result.success(response);
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        result.error("DB_ERROR", error.getMessage(), null);
                    }
                });
    }

    private void fetchUserData(MethodChannel.Result result) {
        FirebaseUser currentUser = FirebaseAuth.getInstance().getCurrentUser();

        if (currentUser != null) {
            String email = (currentUser.getEmail() != null) ? currentUser.getEmail() : "";
            String userId = currentUser.getUid();

            databaseRef.child("User").child(userId)
                    .addListenerForSingleValueEvent(new ValueEventListener() {
                        @Override
                        public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                            String name = (dataSnapshot.child("Username").getValue(String.class) == null)
                                    ? ""
                                    : dataSnapshot.child("Username").getValue(String.class);

                            Map<String, Object> response = new HashMap<>();
                            response.put("name", name);
                            response.put("email", email);

                            result.success(response);
                        }

                        @Override
                        public void onCancelled(@NonNull DatabaseError error) {
                            result.error("DB_ERROR", error.getMessage(), null);
                        }
                    });

        } else {
            result.error("AUTH_ERROR", "User not authenticated", null);
        }
    }

    private void editProfileData(String userId, String name, double weight, double height, double age, MethodChannel.Result result) {
        Map<String, Object> updates = new HashMap<>();
        updates.put("Username", name != null ? name : "Unknown");
        updates.put("Weight", weight > 0 ? weight : 0.0);
        updates.put("Height", height > 0 ? height : 0.0);
        updates.put("Age", age > 0 ? age : 0.0);

        databaseRef.child("User").child(userId).updateChildren(updates)
                .addOnSuccessListener(aVoid -> result.success("Data updated successfully"))
                .addOnFailureListener(e -> result.error("DB_ERROR", e.getMessage(), null));
    }

}
