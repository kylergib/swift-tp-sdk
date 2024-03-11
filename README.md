# Swift SDK for Touch Portal Plugin

This SDK is to create plugins for Touch Portal using swift. It allows you to connect to Touch Portal and create Actions/States/Events/Connectors. Also, I have created a method that will automatically build the entry.tp file for you.

### This SDK is new, so there may be some issues, feel free to open an issue. 

### Please read [Touch Portal API](https://www.touch-portal.com/api/index.php?section=intro) documentation before hand.

### Only works with Touch Portal API 7, may not be backwards compatible, but I have not tested.

## Quick Start

#### I am going to use my project [Mac Control](https://github.com/kylergib/MacControlTP) as an example. My project is laid out differently that what is shown here.

### TPClient:

```swift
/* IS REQUIRED */

/**
* The TPClient class is what handles the communication with Touch Portal
* TPClient has optional parameters of address and port if you do not use localhost and the default port.
*/
var client: TPClient = TPClient()

/**
* TPClient has a few callback methods that you can use
*/

// returns: a list of Bool
client.onConnection = { isConnected in
    print(isConnected ? "connected" : "not connected")
}

// returns an Info object
// when the plugin successfully pairs with Touch Portal, Touch Portal sends the following info.
// here I know it is connected, so I start my plugin's logic
client.onInfo = { info in
    print(info.sdkVersion)
    print(info.tpVersionString)
    print(info.tpVersionCode)
    print(info.pluginVersion)
    print(info.status)
    self.startMonitoringDefaultOutputVolume()
}

// does not return anything
// Touch Portal is requesting that the plugin close, so handle it here.
client.onCloseRequest = {
    DispatchQueue.main.async {
        NSApplication.shared.terminate(nil)
    }
}

// starts the client, if Touch Portal is not open, you may need to restart the plugin (but TP should handle it)
// client.plugin needs to be set from the next section before using client.start()
client.start()
```

### Plugin:

```swift
/* IS REQUIRED */
/**
* The Plugin class is where your categories/actions/events/states/connectors are stored
*/
var plugin: Plugin = Plugin(api: .v7, version: 001, name: "Mac Control", pluginId: "com.maccontrol")

// Callback methods for plugin class

// some things are not needed if you create the entry.tp file yourself
// use %TP_PLUGIN_FOLDER% for the base Touch Portal folder
// the buildEntry method will turn this into: open %TP_PLUGIN_FOLDER%MacControl\/MacControlTP.app
// the extra "\" is fine as JSON uses this as escape character and Touch Portal will parse it correctly
plugin.pluginStartCmdMac = "open %TP_PLUGIN_FOLDER%MacControl/MacControlTP.app"

/* You can specify the following, but is not really necessary if you are running only on Mac */
//plugin.pluginStartCommand: String?
//plugin.pluginStartCmdWindows: String?
//plugin.pluginStartCmdLinux: String?

// after plugin is created you need to tell TPClient
client.plugin = plugin
```

### Configuration

```swift
/* IS NOT REQUIRED */
plugin.configuration = Configuration(parentCategory: ParentCategory.misc)

//* but below is all variables available */
//plugin.configuration = Configuration(parentCategory: ParentCategory.misc, colorDark: String, colorLight: String)

// ParentCategory options:
/*
public enum ParentCategory: String {
    case audio
    case streaming
    case content
    case homeautomation
    case social
    case games
    case misc
}
*/


```

### Category (subcategory):

```swift
/* AT LEAST ONE IS REQUIRED */

let volumeCategory = Category(id: "volume", name: "Volume", imagePath: "")

// adds the category to a [String: Category] to be able to retrieve, an example on lookup in the actions section.
// it is not automatically added.
plugin.addCategory(category: volumeCategory)
```

### Actions:

```swift

// defines the action
let action = Action(id: "setDefaultOutputVolume", name: "Set Default Output Volume", type: ActionType.communicate, category: plugin.categories["volume"]!)

// all parameters of action object
//Action(id: String, name: String, type: ActionType, category: Category, executionType: ExecutionType? = nil, executionCmd: String? = nil)

// if the action does not have data you can skip this.
// ActionDataType.number(0) -> the 0 param is the default value, for text can be an empty string -> ""
action.addData(data: ActionData(id: "defaultOutputVolume", type: ActionDataType.number(0)))

// full actionData class
//some items will not matter depending on what type it is
// i.e. a text data is not affected by allowDecimal
//ActionData(id: String, type: ActionDataType, valueChoices: [String]? = nil, extensions: [String]? = nil, allowDecimal: Bool? = nil, minValue: Int? = nil, maxValue: Int? = nil)

// ActionDataType options
/*
public enum ActionDataType {
    case text(String)
    case number(Int)
    case bool(Bool)
    case choice(String)
    case file(String)
    case folder(String)
    case color(String)

}
*/

// to get default value of a ActionDataType
var value = actionData.getTypeAndValue().defaultValue

// this is a line that you will see in Touch Portal when adding the action
// data: is a list of strings
// use {$VARIABLE_NAME$} to put the ActionData in the line
action.addActionLine(actionLine: ActionLine(data: ["Set volume of default output to: {$defaultOutputVolume$}"]))


// this is an onAction callback
// if you want to do something when an action is pressed from Touch Portal you have to device an .onAction for each action you create.

// response is :
/*
public class Response {
    public var type: String?
    public var pluginId: String?
    public var id: String?
    public var data: [ResponseData]?
    public var value: Any?
    */
// I run it in a background thread to make sure nothing is blocked, but your results may vary.
action.onAction = { response in
    print("action 1")
    //            print(response.data)
    DispatchQueue.global(qos: .background).async {
        let dataList = response.data
        dataList?.forEach { data in
            if data.id == "defaultOutputVolume", data.value != nil {
                if let floatValue = Float(data.value as! String) {
                    _ = AudioDevice.setVolume(volume: floatValue)
                } else {
                    print("The string does not contain a valid floating point number")
                }
            }
        }
    }
}

// monitors when a list is changed inside an action
action.onListChange = { response in
    print(response.values)
}

// you have to manually add the action after creating it.
plugin.addAction(action: action)
```

### Connectors:

```swift
//creates the connector with ConnectorData as dataList
let connector = Connector(id: "defaultOutputVolumeConnector", name: "Default Output Connector", format: "defaultOutputVolumeConnectorLabel", category: plugin.categories["volume"]!, dataList: [])

//example of ConnectorData
//let connectorData = ConnectorData(id: "connectLabel", dataType: ConnectorDataType.number)

// ConnectorDataType options:
/*
public enum ConnectorDataType: String {
    case choice
    case text
    case number
}
*/

// this callback is what runs when this connector is changed from Touch Portal
connector.onConnectorChange = { response in
    DispatchQueue.global(qos: .background).async {
        if (response.value == nil) { return }
        let floatValue = Float(response.value as! Int)/100.00
        print(floatValue)
        _ = AudioDevice.setVolume(volume: floatValue)
    }
}
// you have to add manually.
plugin.addConnector(connector: connector)

// to update a connector from your plugin
// you need connectorId and what value in Int from 0-100
//if above 100 it will just set it to 100 and less than 0 set it to 0
 Connector.updateConnectorData(connectorId: "defaultOutputVolumeConnector", value: Int(newVolume*100))
```

### Notications:

```swift
// an option to click inside the notification in Touch Portal
let notificationOption = NotifcationOption(id: "testno1234ti", title: "this is my title")

// atleast 1 NotifcationOption is required
// options is a list of NotifcationOptions
let notification = TPNotification(id: "one1234", title: "second title", message: "update prolly", options: [notificationOption])

// when a NotifcationOption is clicked in Touch Portal this runs.
// you can use .optionId to see which option was clicked.
notification.onNotificationClicked = { response in
    print(response.optionId)
}

// you have to manually add the notification to the plugin
plugin.addNotification(notification: notification)
```

### Plugin:

```swift
let state1 = State(id: "state1", type: StateType.text, description: "1st state i have", category: plugin.categories["volume"]!, defaultValue: "test")

// have to add to plugin manually
plugin.addState(state: state1)

// two options for StateType
public enum StateType: String {
    case choice
    case text
}
```
### Settings

```swift
// add setting
let setting = Setting(name: "test setting", type: SettingType.number, toolTip: ToolTip(body: "body test"))

// have to add manually
plugin.addSetting(setting: setting)

// This may change to something similar to how actions are handled
// Touch Portal tells the plugin that a setting has changed
// returns: a list of SettingResponse objects
// SettingResponse has a name property and a value property.
plugin.onSettingsChange = { settingsList in
    settingsList.forEach { setting in
        print("settings change: \(setting.name) - \(setting.value)")
    }
}

// tool tip is 
ToolTip(body: "body test")
// full tooltip init if wanting to use it
//ToolTip(body: String, title: String? = nil, docUrl: String? = nil)

//setting types: 
public enum SettingType: String {
    case text
    case number
}

```

### Various update options (lists/states/choices)

```swift
// all of these are static methods

// updates a list with actionDataId inside an action of actionId
Action.updateActionList(actionDataId: String, value: [String], actionId: String)

// updates actionData of actionDataId with an ActionData object
ActionData.updateActionData(actionDataId: String, data: ActionData)

// updates a connector of connectorId with value
Connector.updateConnectorData(connectorId: String, value: Int)

// triggers event of eventId for states
// have not tested yet though
Event.triggerEvent(eventId: String, states: [String: String])

// updates a setting
Setting.updateSetting(settingName:String, value: String)

// updates a state on stateId with value
State.updateState(stateId: String, value: String)

// updates a stateList of stateId with a list of values
State.updateStateList(stateId: String, value: [String])

// updates a choiceList of choiceListId with values
State.updateChoiceList(choiceListId: String, value: [String])

// removes state with id
State.removeState(id: String)
```

### Build entry.tp

```swift
// I have a target that has a custom flag of "ENTRY", so if I run it then it will built the entry.tp file instead of running the plugin.
#if ENTRY
// you can specify what folder you would like it to output to
let path = "~/KamiCloud/Documents/Swift/MacControlTP/build/MacControl"
let expandedPath = NSString(string: path).expandingTildeInPath
let url = URL(fileURLWithPath: expandedPath)

// filename is the name of the output file
// in order to save the file outside of the app sandbox on your mac, you will have to disable app sandbox completely
plugin.buildEntry(folderURL: url, fileName: "entry.tp")

// i want my plugin to terminate after it runs the buildEntry
NSApplication.shared.terminate(nil)
#else
// runs if not in entry target
DispatchQueue.global(qos: .background).async {
    self.client.start()
}
#endif
```

### Misc

To make it easier when building the plugin and creating a .tpp file for Touch Portal, I use a post-action script when building

```sh

BUILD_FOLDER=~/KamiCloud/Documents/Swift/MacControlTP/build

# Define the destination folder where you want to copy the .app
TPP_FOLDER=~/KamiCloud/Documents/Swift/MacControlTP/build/MacControl

# Create the destination folder if it doesn't already exist
mkdir -p "$TPP_FOLDER"

# Remove the .app from the destination folder
rm -rf "$TPP_FOLDER/${PRODUCT_NAME}.app"

# Copy the .app to the destination folder
cp -R "${BUILD_DIR}/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}/${PRODUCT_NAME}.app" "$TPP_FOLDER"

# Navigate to the destination directory
cd "$BUILD_FOLDER"

# Zip the entire folder
zip -r "${PRODUCT_NAME}.tpp" MacControl

## In the buildEntry method I use the same folder, so they are at the same place, but buildEntry is needed to run before this script, or it will not have the entry.tp in the .tpp file

```
