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
