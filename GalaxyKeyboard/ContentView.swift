//
//  ContentView.swift
//  GalaxyKeyboard
//
//  Created by Nodari L on 18.01.26.
//

import SwiftUI

struct ContentView: View {
    @State private var testText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        TabView {
            HomeView(testText: $testText, isTextFieldFocused: $isTextFieldFocused)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            PrivacyPolicyView()
                .tabItem {
                    Image(systemName: "shield.fill")
                    Text("Privacy")
                }
        }
    }
}

struct HomeView: View {
    @Binding var testText: String
    @FocusState.Binding var isTextFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "keyboard.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Galaxy Keyboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your custom keyboard with extended symbols and numbers")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Enable")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    InstructionStep(
                        number: 1,
                        icon: "gearshape.fill",
                        title: "Open Settings",
                        description: "Go to your device Settings app"
                    )
                    
                    InstructionStep(
                        number: 2,
                        icon: "keyboard.fill",
                        title: "Navigate to Keyboards",
                        description: "Tap General → Keyboard → Keyboards"
                    )
                    
                    InstructionStep(
                        number: 3,
                        icon: "plus.circle.fill",
                        title: "Add New Keyboard",
                        description: "Tap 'Add New Keyboard...' and select 'GalaxyKeyboard'"
                    )
                    
                    InstructionStep(
                        number: 4,
                        icon: "checkmark.circle.fill",
                        title: "Enable Full Access (Optional)",
                        description: "For best experience, enable Full Access for GalaxyKeyboard"
                    )
                    
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Open Settings")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Test Area")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Tap the text field below to test your Galaxy Keyboard. Tap the 🌐 globe icon on the keyboard to switch between keyboards.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextEditor(text: $testText)
                            .focused($isTextFieldFocused)
                            .frame(minHeight: 150)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue.opacity(isTextFieldFocused ? 0.5 : 0.2), lineWidth: 1)
                            )
                        
                        if testText.isEmpty {
                            Text("Start typing to test your keyboard...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if !testText.isEmpty {
                            Button(action: {
                                testText = ""
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Clear Text")
                                }
                                .font(.subheadline)
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Galaxy Keyboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("Privacy Policy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Your privacy is our priority")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 20) {
                        PrivacySection(
                            title: "Data Collection",
                            icon: "doc.text.fill",
                            items: [
                                "**No personal data collected**: Galaxy Keyboard does not collect, store, or transmit any personal information",
                                "**No typed text stored**: Your keyboard input is processed locally and never saved or transmitted",
                                "**No analytics or tracking**: The app contains no analytics, crash reporting, or user tracking systems",
                                "**No network access**: The keyboard does not connect to the internet or external servers"
                            ]
                        )
                        
                        PrivacySection(
                            title: "Data Storage",
                            icon: "internaldrive.fill",
                            items: [
                                "**Local processing only**: All keyboard functionality operates entirely on your device",
                                "**No user preferences saved**: The app does not store user settings or preferences",
                                "**No file storage**: No user data is written to device storage beyond standard iOS keyboard functionality",
                                "**No cloud synchronization**: No data is synced to iCloud or other cloud services"
                            ]
                        )
                        
                        PrivacySection(
                            title: "Permissions",
                            icon: "checkmark.shield.fill",
                            items: [
                                "**No special permissions required**: The keyboard operates with standard iOS keyboard permissions only",
                                "**Full Access not required**: The keyboard works without Full Access, though enabling it may improve performance",
                                "**No camera, microphone, or location access**: The app does not request access to device sensors or location services",
                                "**No contacts or calendar access**: The app does not access your contacts, calendar, or other personal data"
                            ]
                        )
                        
                        PrivacySection(
                            title: "Third-Party Services",
                            icon: "network",
                            items: [
                                "**No third-party integrations**: The app does not use any third-party services, SDKs, or frameworks that could collect data",
                                "**No advertising**: The app contains no advertisements or advertising networks",
                                "**No external dependencies**: All functionality is built using standard iOS frameworks only"
                            ]
                        )
                        
                        PrivacySection(
                            title: "Contact Information",
                            icon: "envelope.fill",
                            items: [
                                "**Questions about privacy**: Contact the developer through the App Store if you have privacy-related questions",
                            ]
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PrivacySection: View {
    let title: String
    let icon: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                            .font(.system(size: 16, weight: .bold))
                        
                        Text(LocalizedStringKey(item))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.leading, 32)
        }
        .padding(.vertical, 8)
    }
}

struct InstructionStep: View {
    let number: Int
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}
