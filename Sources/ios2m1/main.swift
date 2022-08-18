import Foundation
import ArgumentParser

struct ios2m1: ParsableCommand {
    
    @Argument(help: "Path to .ipa or .app")
    var input: String
    
    @Option(name: .shortAndLong, help: "Output folder")
    var output: String?
    
    @Flag(name: .shortAndLong, help: "Verbose logging")
    private var verbose: Bool = false
    
    @Flag(name: .shortAndLong, help: "Remove quarantine attributes from final product")
    private var removeQuarantine: Bool = false
    
    @Flag(name: .shortAndLong, help: "Move final product to /Applications folder")
    private var moveToApps: Bool = false
    
    func run() throws {
        
        /// If input file does not exist, throw
        guard FileManager.default.fileExists(atPath: input) else {
            throw ArgumentError.missingIpa
        }

        /// Get input URL
        let inputUrl = URL(fileURLWithPath: input)
        debugLog("Input URL: \(inputUrl.path)")

        /// if input file is not .ipa nor .app, throw
        guard ["ipa", "app"].contains(inputUrl.pathExtension)  else {
            throw ArgumentError.wrongFormat
        }
        
        /// Get output folder
        var outputFolder: URL
        if let output = output {
            outputFolder = URL(fileURLWithPath: output)
        } else {
            outputFolder = inputUrl.deletingLastPathComponent()
        }
        debugLog("Output folder: \(outputFolder.path)")
        
        /// Define isIpa boolean
        let isIpa = inputUrl.pathExtension == "ipa"
        debugLog("Is ipa: \(isIpa)")
        
        /// Utility func to delete folder at given url
        func deleteFolder(at url: URL) throws {
            if FileManager.default.fileExists(atPath: url.path) {
                debugLog("Clearing \(url.path)")
                try FileManager.default.removeItem(atPath: url.path)
            }
        }
        
        /// Define work folder
        let workFolder = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("ios2m1", isDirectory: true)
        debugLog("Work folder: \(workFolder.path)")
        
        var dotApp: URL = inputUrl
        
        /// If .ipa, unzip file to tmp folder
        if isIpa {
            let payloadFolder = workFolder.appendingPathComponent("Payload", isDirectory: true)
            
            /// Clear folder if it already exists
            try deleteFolder(at: payloadFolder)
            
            print("Unzipping ipa...")
            
            /// using unzip instead.
            shell("unzip -oq \(inputUrl.path) -d \(workFolder.path)")
            
            /// Get .app folder inside Payload
            let payloadContents = try FileManager.default.contentsOfDirectory(at: payloadFolder, includingPropertiesForKeys: nil)
            guard let appFolder = payloadContents.first(where: { $0.pathExtension == "app" }) else {
                throw ArgumentError.missingDotApp
            }
            dotApp = appFolder
            debugLog("dot app folder: \(dotApp.path)")
        }
        
        /// Get app name from Info.plist
        var appName: String
        let infoPlist = dotApp.appendingPathComponent("Info.plist", isDirectory: false)
        guard FileManager.default.fileExists(atPath: infoPlist.path) else {
            throw ArgumentError.missingInfoPlist
        }
        let data = try Data(contentsOf: infoPlist)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String : Any]
        if let name = plist?["CFBundleDisplayName"] as? String {
            appName = name
        } else if let name = plist?["CFBundleName"] as? String {
            appName = name
        } else {
            throw ArgumentError.missingName
        }
        debugLog("appName: \(appName)")
        
        let finalProduct = outputFolder.appendingPathComponent("\(appName).app")

        /// delete .app if already exists
        try deleteFolder(at: finalProduct)

        /// create Wrapper folder
        print("Creating Wrapper folder...")
        let wrapperPath = finalProduct.appendingPathComponent("Wrapper")
        try FileManager.default.createDirectory(atPath: wrapperPath.path, withIntermediateDirectories: true, attributes: nil)
        debugLog("Wrapper path: \(wrapperPath.path)")
        
        /// Copy original .app contents
        print("Copying files...")
        try FileManager.default.copyItem(
            atPath: dotApp.path,
            toPath: wrapperPath.appendingPathComponent(dotApp.lastPathComponent).path
        )
        
        /// Create symbolic link
        print("Creating symbolic link...")
        try FileManager.default.createSymbolicLink(
            atPath: finalProduct.appendingPathComponent("WrappedBundle").path,
            withDestinationPath: "Wrapper/\(dotApp.lastPathComponent)"
        )
        
        /// Cleanup
        if isIpa {
            print("Cleaning up...")
            try deleteFolder(at: workFolder.appendingPathComponent("Payload", isDirectory: true))
        }
        
        /// Remove quarantine attributes
        if removeQuarantine {
            print("Removing quarantine attributes...")
            shell("xattr -dr com.apple.quarantine \(finalProduct.path)")
        }
        
        /// Finish
        if moveToApps {
            print("Moving to /Applications...")
            shell("mv \(finalProduct.path) /Applications")
            print("Done!")
        } else {
            print("Done! App path: \(finalProduct.path)")
        }
    }
    
    /// Debug log func
    func debugLog(_ message: String) {
        if verbose {
            print(message)
        }
    }
    
    /// Run given shell command
    func shell(_ command: String) {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["bash", "-c", command]
        process.launch()
        process.waitUntilExit()
    }
}

ios2m1.main()
