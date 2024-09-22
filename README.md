# FFmpegManager

FFmpegManager is a Swift-based library designed to simplify and manage FFmpeg tasks. It provides a streamlined way to execute FFmpeg commands, manage execution queues, track progress, and handle media information. This package is powered by the ffmpegkit framework and can be easily integrated into iOS/macOS projects.


## Features

- **Execute FFmpeg commands: Run FFmpeg commands asynchronously with argument support.
- **Execution Queue Management: Execute multiple FFmpeg processes in order with priority control.
- **Track Progress: Monitor the progress of FFmpeg tasks, including media length, current processing time, and overall percentage.
- **Cancel Tasks: Cancel any queued or ongoing FFmpeg tasks.
- **Retrieve Media Information: Extract media file details using FFprobeKit.
- **Screen Control: Prevent the device from going to sleep during long-running FFmpeg processes.


## Installation

### Swift Package Manager (SPM)

To integrate `FFmpegManager` into your project using Swift Package Manager, add the following dependency in your `Package.swift` file:

```swift
.package(url: "https://github.com/mohamedaglan2225/FFmpegManager.git", from: "1.0.0")
```

## Usage

### 1. import FFmpegManager


```
import FFmpegManager
```


### 2.  Executing FFmpeg Commands

```
FFmpegManager.shared.execute(withArguments: ["-i", "input.mp4", "output.mp4"]) { status, tag in
    switch status {
    case .didSuccess:
        print("FFmpeg process succeeded with tag: \(tag ?? -1)")
    case .didFail:
        print("FFmpeg process failed with tag: \(tag ?? -1)")
    case .inWaitList:
        print("Process is in the waitlist.")
    case .willExecute:
        print("Process will be executed.")
    }
}

```

### 3. Managing Command Queues

```
FFmpegManager.shared.execute(withArguments: ["-i", "input.mp4", "output.mp4"], level: 2000) { status, tag in
    // Handle response
}


```

### 4. Tracking Progress

```

FFmpegManager.shared.execute(withArguments: ["-i", "input.mp4", "output.mp4"],
                             progress: { current, total, progress in
                                 print("Progress: \(progress * 100)%")
                             }) { status, tag in
                                 // Handle completion
                             }

```


### 5. Cancelling Tasks

```

FFmpegManager.shared.cancel(tag: 1)

```


### 6. Retrieve Media Information

```

let mediaInfo = FFmpegManager.shared.getMediaInformation(path: "input.mp4")
print(mediaInfo)

```

### 7. Screen Activity Control

```

ScreenController.shared.startKeepScreenActive()
ScreenController.shared.stopKeepScreenActive()


```







