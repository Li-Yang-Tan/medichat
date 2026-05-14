package com.example.fyp.Admin;

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

public class AdBlog implements FlutterPlugin, MethodChannel.MethodCallHandler  {
    private DatabaseReference databaseRef;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "AdBlog");
        channel.setMethodCallHandler(this);
        databaseRef = FirebaseDatabase.getInstance("https://medichat-2029e-default-rtdb.asia-southeast1.firebasedatabase.app").getReference();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("UploadBlog")){
            String date = call.argument("date");
            String title = call.argument("title");
            String description = call.argument("description");
            String link = call.argument("link");

            addToDB(date, title, description, link, result);
        } else {
            result.notImplemented();
        }
    }

    public void addToDB(String date, String title, String body, String link, MethodChannel.Result result) {
        databaseRef.child("Blog").child(date).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if (dataSnapshot.exists()) {

                    // Record exists, notify the listener
                    databaseRef.child("Blog").child(date).addListenerForSingleValueEvent(new ValueEventListener() {
                        @Override
                        public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                            Map<String, Object> blogData = new HashMap<>();
                            blogData.put("Description", body);
                            blogData.put("Link", link);

                            Map<String, Object> blogData2 = new HashMap<>();
                            blogData2.put(title, blogData);

                            databaseRef.child("Blog").child(date).updateChildren(blogData2).addOnCompleteListener(new OnCompleteListener<Void>() {
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

                        @Override
                        public void onCancelled(@NonNull DatabaseError databaseError) {
                            // Handle potential errors
                            result.error("recorde", "Error while checking the existing record.", null);
                        }
                    });
                } else {
                    Map<String, Object> blogData = new HashMap<>();
                    blogData.put("Description", body);
                    blogData.put("Link", link);

                    Map<String, Object> blogData2 = new HashMap<>();
                    blogData2.put(title, blogData);

                    Map<String, Object> blogData3 = new HashMap<>();
                    blogData3.put(date, blogData2);

                    // Execute query to add the new record
                    databaseRef.child("Blog").updateChildren(blogData3).addOnCompleteListener(new OnCompleteListener<Void>() {
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
}
