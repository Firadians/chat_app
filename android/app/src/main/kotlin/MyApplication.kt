package com.example.chat_app  // Replace with your actual package name

import android.app.Application
import androidx.multidex.MultiDex
import androidx.multidex.MultiDexApplication

class MyApplication : MultiDexApplication() {
    override fun attachBaseContext(base: android.content.Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}
