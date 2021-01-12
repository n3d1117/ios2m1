# ios2m1
[![Platform](http://img.shields.io/badge/platform-macOS-red.svg?style=flat)](https://developer.apple.com/resources/)
[![Platform](https://img.shields.io/badge/swift-5.0-orange.svg?style=flat)](https://swift.org/blog/swift-5-released/)

A macOS command line tool to convert iOS apps (`.ipa` or `.app`) to Apple M1 apps.

## Screenshot
![](https://user-images.githubusercontent.com/11541888/104328919-a0b28080-54ec-11eb-9509-012f4d5db0a8.png)

## Usage
```
USAGE: ios2m1 <input> [--output <output>] [--verbose] [--remove-quarantine] [--move-to-apps]

ARGUMENTS:
  <input>                 Path to .ipa or .app 

OPTIONS:
  -o, --output <output>   Output folder 
  -v, --verbose           Verbose logging 
  -r, --remove-quarantine Remove quarantine attributes from final product 
  -m, --move-to-apps      Move final product to /Applications folder 
  -h, --help              Show help information.
```

## Requirements
* Apple M1 mac
* A signed `.ipa` or `.app` file

## Build instructions
```bash
$ git clone https://github.com/n3d1117/ios2m1.git
$ cd ios2m1
$ swift build -c release
$ cp -f .build/release/ios2m1 /usr/local/bin/ios2m1
```
Done! You can now use `ios2m1`within any folder from the terminal.

## Credits
* [ipodtouchdude/iOS-2-M1](https://github.com/ipodtouchdude/iOS-2-M1)