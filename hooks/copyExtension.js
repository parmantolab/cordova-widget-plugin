/**
 * Created by tony on 7/12/17.
 */
'use strict'

var xcode = require('xcode');
var fs = require('fs');
var path = require('path');
var recursiveCopy = require('recursive-copy')
var glob = require('glob')


function findProjectPath(projectRoot) {
  var ProjectFolderPattern = /.*[.]xcodeproj/
  for (var name of fs.readdirSync(projectRoot)) {
    if (ProjectFolderPattern.test(name)) {
      return path.join(projectRoot,name,"project.pbxproj")
    }
  }
}

function getAppBundleId(configFilePath) {
  var config = fs.readFileSync(configFilePath).toString()
  var match = /id="([^"]+)"/.exec(config)
  return match[1]
}


function log(text) {
  console.log("lock screen widget: " + text);
}

module.exports = function (context) {
  var Q = context.requireCordovaModule('q');
  var fs = context.requireCordovaModule('fs');
  var path = context.requireCordovaModule('path');
  var deferral = new Q.defer();
  var iosFolder = path.join(context.opts.projectRoot, 'platforms/ios/')
  var widgetName = "MedicalWidget"
  
  
  recursiveCopy(path.join(context.opts.plugin.dir, widgetName),path.join(iosFolder,widgetName),(err,result)=>{
    if (err) {
      deferral.reject()
    }
    else {

      var projectPath = findProjectPath(iosFolder)
      var appConfigFilePath = path.join(iosFolder,glob.sync("**/config.xml",{cwd:iosFolder})[0])
      var appBundleId = getAppBundleId(appConfigFilePath)
      
      var appFolder  = path.resolve(appConfigFilePath,"..")
      var productNameFromFile = path.basename(appFolder)
      fs.writeFileSync(path.join(appFolder, productNameFromFile + ".entitlements"),'<?xml version="1.0" encoding="UTF-8"?>' +
      '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' +
      '<plist version="1.0">' +
        '<dict>' +
        '<key>com.apple.security.application-groups</key>' +
        '<array>' +
        '<string>group.tony.app-widget-e1</string>' +
        '</array>' +
        '</dict>' +
        '</plist>'
      )
      
      var pbxProject = xcode.project(projectPath);
      pbxProject.parseSync();
  
      pbxProject.pbxGroupByName('CustomTemplate')

      var widgetFolder = path.join(iosFolder, widgetName);
      var sourceFiles = [];
      var resourceFiles = [];
      var configFiles = [];
      var projectContainsSwiftFiles = false;
      var addBridgingHeader = false;
      var bridgingHeaderName;
      var addXcconfig = false;
      var xcconfigFileName;
      var xcconfigReference;
      var addEntitlementsFile = false;
      var entitlementsFileName;

      fs.readdirSync(widgetFolder).forEach(file => {
        if (!/^\..*/.test(file)) {
          // Ignore junk files like .DS_Store
          var fileExtension = path.extname(file);
          switch (fileExtension) {
            // Swift and Objective-C source files which need to be compiled
            case '.swift':
              projectContainsSwiftFiles = true;
              sourceFiles.push(file);
              break;
            case '.h':
            case '.m':
              if (file === 'Bridging-Header.h' || file === 'Header.h') {
                addBridgingHeader = true;
                bridgingHeaderName = file;
              }
              sourceFiles.push(file);
              break;
            // Configuration files
            case '.plist':
            case '.entitlements':
            case '.xcconfig':
              if (fileExtension == '.xcconfig') {
                addXcconfig = true;
                xcconfigFileName = file;
              }
              if (fileExtension == '.entitlements') {
                addEntitlementsFile = true;
                entitlementsFileName = file;
              }
              configFiles.push(file);
              break;
            // Resources like storyboards, images, fonts, etc.
            default:
              resourceFiles.push(file);
              break;
          }
        }
      });

      log('Found following files in your widget folder:', 'info');
      console.log('Source-files: ');
      sourceFiles.forEach(file => {
        console.log(' - ', file);
      });

      console.log('Config-files: ');
      configFiles.forEach(file => {
        console.log(' - ', file);
      });

      console.log('Resource-files: ');
      resourceFiles.forEach(file => {
        console.log(' - ', file);
      });

      // Add PBXNativeTarget to the project
      var target = pbxProject.addTarget(
        widgetName,
        'app_extension',
        widgetName
      );
      if (target) {
        log(target, 'info');
      }

      // Create a separate PBXGroup for the widgets files, name has to be unique and path must be in quotation marks
      var pbxGroupKey = pbxProject.pbxCreateGroup(
        'Widget',
        '"' + widgetName + '"'
      );
      if (pbxGroupKey) {
        log(
          'Successfully created empty PbxGroup for folder: ' +
          widgetName +
          ' with alias: Widget',
          'info'
        );
      }

      // Add the PbxGroup to cordovas "CustomTemplate"-group
      var customTemplateKey = pbxProject.findPBXGroupKey({
        name: 'CustomTemplate',
      });
      pbxProject.addToPbxGroup(pbxGroupKey, customTemplateKey);
      log(
        'Successfully added the widgets PbxGroup to cordovas CustomTemplate!',
        'info'
      );

      // Add files which are not part of any build phase (config)
      configFiles.forEach(configFile => {
        var file = pbxProject.addFile(configFile, pbxGroupKey);
        // We need the reference to add the xcconfig to the XCBuildConfiguration as baseConfigurationReference
        if (path.extname(configFile) == '.xcconfig') {
          xcconfigReference = file.fileRef;
        }
      });
      log(
        'Successfully added ' + configFiles.length + ' configuration files!',
        'info'
      );

      // Add a new PBXSourcesBuildPhase for our TodayViewController (we can't add it to the existing one because a today extension is kind of an extra app)
      var sourcesBuildPhase = pbxProject.addBuildPhase(
        [],
        'PBXSourcesBuildPhase',
        'Sources',
        target.uuid
      );
      if (sourcesBuildPhase) {
        log('Successfully added PBXSourcesBuildPhase!', 'info');
      }

      // Add a new source file and add it to our PbxGroup and our newly created PBXSourcesBuildPhase
      sourceFiles.forEach(sourcefile => {
        pbxProject.addSourceFile(
          sourcefile,
          { target: target.uuid },
          pbxGroupKey
        );
      });

      log(
        'Successfully added ' +
        sourceFiles.length +
        ' source files to PbxGroup and PBXSourcesBuildPhase!',
        'info'
      );

      // Add a new PBXFrameworksBuildPhase for the Frameworks used by the widget (NotificationCenter.framework, libCordova.a)
      var frameworksBuildPhase = pbxProject.addBuildPhase(
        [],
        'PBXFrameworksBuildPhase',
        'Frameworks',
        target.uuid
      );
      if (frameworksBuildPhase) {
        log('Successfully added PBXFrameworksBuildPhase!', 'info');
      }

      // Add the frameworks needed by our widget, add them to the existing Frameworks PbxGroup and PBXFrameworksBuildPhase
      var frameworkFile1 = pbxProject.addFramework(
        'NotificationCenter.framework',
        { target: target.uuid }
      );
      var frameworkFile2 = pbxProject.addFramework('libCordova.a', {
        target: target.uuid,
      }); // seems to work because the first target is built before the second one
      if (frameworkFile1 && frameworkFile2) {
        log('Successfully added frameworks needed by the widget!', 'info');
      }

      // Add a new PBXResourcesBuildPhase for the Resources used by the widget (MainInterface.storyboard)
      var resourcesBuildPhase = pbxProject.addBuildPhase(
        [],
        'PBXResourcesBuildPhase',
        'Resources',
        target.uuid
      );
      if (resourcesBuildPhase) {
        log('Successfully added PBXResourcesBuildPhase!', 'info');
      }

      //  Add the resource file and include it into the targest PbxResourcesBuildPhase and PbxGroup
      resourceFiles.forEach(resourcefile => {
        pbxProject.addResourceFile(
          resourcefile,
          { target: target.uuid },
          pbxGroupKey
        );
      });

      log(
        'Successfully added ' + resourceFiles.length + ' resource files!',
        'info'
      );

      // Add build settings for Swift support, bridging header and xcconfig files
      var configurations = pbxProject.pbxXCBuildConfigurationSection();
      for (var key in configurations) {
        if (typeof configurations[key].buildSettings !== 'undefined') {
          var buildSettingsObj = configurations[key].buildSettings;
          if (typeof buildSettingsObj['PRODUCT_NAME'] !== 'undefined') {
            var productName = buildSettingsObj['PRODUCT_NAME'];
            if (productName.indexOf('Widget') >= 0) {
              // currently it's hard code here, will read it from outside in the future
              buildSettingsObj['PRODUCT_BUNDLE_IDENTIFIER'] = appBundleId + ".MedicalWidget"
              if (addXcconfig) {
                configurations[key].baseConfigurationReference =
                  xcconfigReference + ' /* ' + xcconfigFileName + ' */';
                log('Added xcconfig file reference to build settings!', 'info');
              }
              if (addEntitlementsFile) {
                buildSettingsObj['CODE_SIGN_ENTITLEMENTS'] = '"' + widgetName + '/' + entitlementsFileName + '"';
                log('Added entitlements file reference to build settings!', 'info');
              }
              if (projectContainsSwiftFiles) {
                // buildSettingsObj['SWIFT_VERSION'] = '3.0';
                // buildSettingsObj['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] =
                //   'YES';
                // log('Added build settings for swift support!', 'info');
              }
              if (addBridgingHeader) {
                buildSettingsObj['SWIFT_OBJC_BRIDGING_HEADER'] =
                  '"$(PROJECT_DIR)/' +
                  widgetName +
                  '/' +
                  bridgingHeaderName +
                  '"';
                log('Added bridging header reference to build settings!', 'info');
              }
            }
            else {
              buildSettingsObj['CODE_SIGN_ENTITLEMENTS'] = '"' + productNameFromFile + '/' + productNameFromFile + ".entitlements" + '"';
            }
          }
        }
      }

      // Write the modified project back to disc
      log('Writing the modified project back to disk ...', 'info');
      console.log(buildSettingsObj);

      fs.writeFileSync(projectPath, pbxProject.writeSync());

      deferral.resolve()
    }
  })
  
  return deferral.promise
}