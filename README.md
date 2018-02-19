# ImageIOAPNGTest
Image/IO Framework for APNG test

# What for

I found that Image/IO framework support [APNG](https://en.wikipedia.org/wiki/APNG) image format from iOS 8 and macOS 10.10. However, it seems that the implementation on macOS only contains issue to correctlly decode some valid APNG. 

I find the some valid APNG files(You can check in Chrome for Mac broswer), which the binary files contains multiple `fdAT` chunk between animation frames may cause macOS parse failed. However, it works from iOS 8 to iOS 11. Only the chunk only contains one `fcTL` and `fdAT` each frame can be decoded. 

This does not respect to the APNG specification which allow multiple `fdAT` trunk between frames. The specification is here : [APNG_Specification](https://wiki.mozilla.org/APNG_Specification)

# Test image

+ `image1.png`: 320x240, 101 frames, [source](http://littlesvr.ca/apng/images/GenevaDrive.png)
+ `image1.gif`: 320x240, 101 frames, [source](http://littlesvr.ca/apng/images/GenevaDrive.gif)
+ `image2.png`: 418x309, 79 frames, encode to APNG from [source](http://assets.sbnation.com/assets/2512203/dogflops.gif)

# Test case

+ Decode `image1.png`: success on macOS & iOS
+ Decode `image1.gif`, then encode to temp APNG data, finally decode APNG data again: fail on macOS but success on iOS
+ Decode `image2.png`: fail on macOS but success on iOS

# Issue

When trying to find the issue on macOS, I set a breakpoint at `ImageIO::LogDebug()` symbol, it "trigger" the log like this (Actually no log on release mode Image/IO framework, but the stack trace contains information):

```
CountProc, *** bad fcTL.sequence_number: %d/%d\n
```

It seems that Image/IO's `PNGReadPlugin` could not parse the `fcTL` sequence number correctly. However, both the `image1.png` and `image2.png` is valid according to the APNG specification and the sequence number increment is correct. You can use any image tool or Hex editor to check.

# How to run

No any dependency expect Image/IO framework itself, just download and open `ImageIOAPNGTest.xcworkspace`, choose iOS or macOS target to build.