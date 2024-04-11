# Goose

## What is Goose ?
Goose is a utility app designed to streamline notification management on your device. It acts as your trusty sidekick, keeping track of pending notifications and providing timely alerts for effortless organization.

## Why was it developed ?
Goose was born out of the frustration of dealing with missed notifications across multiple apps.

In the macOS environment, the bliss of hiding the Dock, immersing in a full-screen window, and concentrating on tasks is unparalleled. However, reality often interrupts this ideal scenario. Teammates may require assistance at any moment, and in the midst of focus mode, responses can slip one's mind.

Messaging platforms such as Mail, Slack, and Microsoft Teams lack a menu bar icon altogether. Consequently, when working in a full-screen window or utilizing an additional monitor that hides the Dock, unread messages go unnoticed.

## How does Goose work ?
            
Goose App harnesses the macOS Accessibility API to synchronize the latest badge text from every monitored app in the Dock element to the menu bar.

Due to the constraints of the Accessibility API, which cannot observe changes in element attributes, Goose App adopts a polling approach, syncing badges periodically.

## Why is Goose not on Mac App Store ?
Simple. Apple does not allow non-sandboxed apps on the App Store and sandboxing Goose will restrict its functionality. Goose needs to access the Dock to monitor notifications and the Accessibility API to read the badge text. These permissions are not available in a sandboxed environment.
        
## Main features of Goose:

#### Smart Monitoring: Goose continuously monitors pending notifications from various apps installed on your device.
    
#### Instant Alerts: Receive notifications from Goose whenever there are pending alerts, ensuring you stay informed and up-to-date. Goose can notify via Sound, Notification, Flash or by making an HTTP request.
#### Accessible Status Bar: Easily access notifications from the status bar, providing a convenient and centralized location for all your pending alerts.
#### Customizable Settings: Tailor Goose to your preferences with customizable settings, allowing you to optimize your notification experience.
#### User-Friendly Interface: Goose boasts an intuitive and user-friendly interface, making it easy for anyone to manage their notifications effectively.
            
## Installation :

Open XCode, XCode should automatically install SPM packages

Add Signing information -> Apple Dev Team ID + Provisioning Profiles (Use Automatic Signing for some ease in life)
