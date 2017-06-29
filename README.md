# Administrator Setup

These are the steps for setting up the **_AddressFinder_** Lightning App for Salesforce.

It is assumed that the user performing these steps has _customization_ privileges for their Salesforce application.

If you complete the [Setup Steps](#setup-steps) below and the _AddressFinder_ service is not auto-suggesting addresses as it should, please refer to the [Troubleshooting](troubleshooting.md) section.

## Setup Steps
There are only **three** steps to setting the _AddressFinder_ plugin correctly.
1. [Install the _AddressFinder_ plugin from the Lightning App Exchange as you would with any plugin.](#install-plugin-from-the-lightning-app-exchange)
1. [Add your _AddressFinder_ account key as a record in the _AddressFinder Config Custom Setting_.](#setup-account-key)
1. [Add **addressfinder.io** to you app's Trusted Sites](#add-addressfinder-to-your-trusted-sites)
1. [Add the plugin's Lightning Component to any record page layouts with which you wish to use the _AddressFinder_ service.](#add-plugin-to-record-page)

(More details are provided :point_down: - click the links :point_up: to go straight to the appropriate section below)


### 1. Install Plugin From The AppExchange
* Go to the AppExchange
    * **Either**, via your app:
        * `App Launcher` -> `Visit AppExchange` (top right)
        * search for 'AddressFinder' (one word)
    * **Or**, directly from our [app homepage on the AppExchange](https://appexchange.salesforce.com/) **TODO**
* Click `Get It Now` 
* Log in (as required)


### 2. Setup Account Key
* Goto `Setup`
    * -> `Custom Code` -> `Custom Settings` 
    * -> `Manage` next to the _AddressFinder Config_ name
    * -> `New`
        * _Name_ - any name you wish to give it
        * _Country Code_ - either 'nz' for New Zealand or 'au' for Australia)
        * _Key_ - your _AddressFinder_ account key (can be found at [your _AddressFinder_ portal](https://portal.addressfinder.io/portal))
        * `Save`
        
### 3. Add AddressFinder To Your Trusted Sites
**NB** this only allows your site to make requests to _addressfinder.io_. These can be monitored via the browser developer tools to see in detail.
* Goto `Setup`
    * -> `CSP Trusted Sites` -> `New Trusted Site`
        * _Trusted Site Name_ - any name you wish to give it
        * _Trusted Site URL_ - _https://api.addressfinder.io _
        * `Save`


### 4. Add Plugin to Record Page
* Goto `Setup`
    * select `Lightning App Builder` -> `New`
    * select `Record Page` -> `Next`
    * Fill in `Label` and select the `Object` (that has an address e.g. _User_)
    * Select `Clone Salesforce Default Page` -> `Finish`
    * Type `AddressFinder` into the search box
        * Click on `AddressFinder` (under `Custom`)
        * Click `Activation`
            * Click `Org Default` -> `Assign As Org Default` -> `Close`
            * `Save`
    * PROFIT
