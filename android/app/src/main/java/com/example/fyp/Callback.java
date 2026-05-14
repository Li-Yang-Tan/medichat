package com.example.fyp;

public interface Callback {
    void onSuccess(String message);
    void onFailure(String errorMessage);
}
