package com.example.fyp;

import com.example.fyp.Add.AddMeal;
import com.example.fyp.Add.AddPreset;
import com.example.fyp.Add.AddWater;
import com.example.fyp.Add.AddWeight;
import com.example.fyp.Add.AddWorkout;
import com.example.fyp.Admin.AdBlog;
import com.example.fyp.Admin.AdFeedback;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        flutterEngine.getPlugins().add(new Setup());
        flutterEngine.getPlugins().add(new Chat());
        flutterEngine.getPlugins().add(new Water());
        flutterEngine.getPlugins().add(new Calory());
        flutterEngine.getPlugins().add(new ListView());
        flutterEngine.getPlugins().add(new AddWeight());
        flutterEngine.getPlugins().add(new AddWater());
        flutterEngine.getPlugins().add(new AddWorkout());
        flutterEngine.getPlugins().add(new AddMeal());
        flutterEngine.getPlugins().add(new SetTarget());
        flutterEngine.getPlugins().add(new Profile());
        flutterEngine.getPlugins().add(new Delete());
        flutterEngine.getPlugins().add(new Weight());
        flutterEngine.getPlugins().add(new Feedback());
        flutterEngine.getPlugins().add(new Blog());
        flutterEngine.getPlugins().add(new Image());
        flutterEngine.getPlugins().add(new AdBlog());
        flutterEngine.getPlugins().add(new AdFeedback());
        flutterEngine.getPlugins().add(new AddPreset());
    }
}
