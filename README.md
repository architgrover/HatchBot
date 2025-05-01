# 🐣 Hatch Bot — A SwiftUI Chat Interface

## Overview

**Hatch Bot** is a SwiftUI-based chat interface that features a **bottom sheet** for message input, AI responses, and media attachments. The app provides smooth transitions, dynamic font resizing for text input, and integrates a camera roll for selecting images. The chat supports multi-line typing with automatic font resizing, and offers both **compact** and **expanded** bottom sheet modes.

## Features

- 💬 **Interactive Chat Interface**: A bottom sheet UI with a multi-line text input area for chatting.
- 📸 **Camera Roll Integration**: Supports adding images to the chat by selecting from the photo library.
- 🎨 **Dynamic Font Resizing**: Adjusts font size based on the amount of text entered.
- ⌨️ **Smooth Keyboard Management**: Keyboard adjusts dynamically with the bottom sheet when typing.
- 🧠 **AI Chat Responses**: Mock AI bot responds to user input with a typing animation.
- 🎛️ **Expandable and Collapsible Sheet**: The bottom sheet can expand or minimize based on user interaction.

## Behavior

### 1. **Bottom Sheet Behavior**
- The user sees a **bottom sheet** (or drawer) overlaid on the chat view, containing:
  - Default placeholder text: "Start Typing..."
  - A horizontally scrollable stack of chips with text above the sheet (for suggested messages).
  
### 2. **Typing Behavior**
- **Tapping the sheet** opens the keyboard and allows typing.
- **Multi-line text** input is supported.
- **Dynamic font resizing** for the text input:
  - Default font size: 18pt
  - Font resizes to 16pt and 14pt as text exceeds the available space in the input area.
  - Text becomes **scrollable** if font resizing doesn't fit the content.
  - **Font resizing** is responsive with smooth transitions and minimal jitter.

### 3. **Dismissal Behavior**
- **Dragging the sheet** downward animates both the keyboard and sheet back to their initial state.
- The **animation** should follow the user's finger and only complete if the user releases mid-gesture, respecting the threshold for dismissal.

### 4. **Expand & Minimize Transitions**
- **Expandable Mode**: If any text has been typed, the user can tap an expand icon to make the sheet full-screen.
  - Font size resets to **18pt** in expanded mode.
- **Minimize Mode**: The user can minimize the sheet back to its compact version with a minimize icon.
  - Font size adjusts again based on the dynamic resizing logic.
  - Transitions should be smooth, with animations.
  - When expanded, the background **dims slightly** for visual clarity.

### 5. **Camera Roll Integration**
- A **photos icon** at the bottom opens the camera roll.
- **Semi-expanded view**: The camera roll is presented in a 3-column scrollable grid.
- **Photo Selection**: Tapping on a photo selects it, closing the camera roll and slightly expanding the sheet to show a thumbnail preview below the text input.

## Architecture

- **`ChatView`**: Manages state for keyboard height, bottom sheet size, and message data.
- **`ChatMessageList`**: Displays the list of messages and handles smooth scrolling to the latest message.
- **`BottomSheet`**: Contains the input area, photo picker, and buttons for expanding or minimizing the sheet.
- **`Message` Model**: Represents each chat message, including text and images.
- **Dynamic Font Resizing**: Handles the resizing logic based on the amount of text entered.
- **Keyboard Observers**: Dynamically adjusts the UI when the keyboard appears or disappears.

## Requirements

- iOS 15+
- Swift 5.7+
- Xcode 14+

## Setup

1. Open the `.xcodeproj` file in Xcode.
2. Build and run on a simulator or device.

## Future Improvements

- Add more media types (audio, video) to the chat.
- Improve accessibility features such as VoiceOver support.
- Enhance responsiveness for different screen sizes.
- Integrate a real AI backend (e.g., OpenAI or a local LLM) for smarter responses.
- Implement persistent storage for chat history.
