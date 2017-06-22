# Administrator Setup

These are the steps for setting up the **AddressFinder** Plugin for Salesforce Lightning (_force.com_).

It is assumed that the user performing these steps has _customization_ privileges for their Salesforce application. 

## Setup Steps
There are only **three** steps to setting the **AddressFinder** plugin correctly.
1. [Install the **AddressFinder** plugin from the Lightning App Exchange as you would with any plugin.](#install-plugin-from-the-lightning-app-exchange)
1. [Add your **AddressFinder** account key as a record in the _AddressFinder Config Custom Setting_.](#setup-account-key)
1. [Add the **AddressFinder** plugin to any record page layouts with which you wish to use the **AddressFinder** service.](#add-plugin-to-record-page)

(More details are provided :point_down: - click the links :point_up: to go straight to the appropriate section below)


### Salesforce Admin Setup

#### Install Plugin From The Lightning App
* Go to the AppExchange
    * Either, via your app: <br>_App Launcher_ -> _Visit AppExchange_ (top right) and search for **AddressFinder** (one word)
    * or, directly from our [app homepage on the AppExchange](https://appexchange.salesforce.com/) **TODO**
* Click _Get It Now_ 
* Log in (as required)


#### Setup Account Key
* Goto _Setup_
    * -> _Custom Code_ -> _Custom Settings_ 
    * -> _Manage_ on __AddressFinder Config__
    * -> _New_
        * _Name_ (can be anything)
        * _Country Code_ (either 'nz' for New Zealand or 'au' for Australia)
        * _Key_ - your **AddressFinder** account key (can be found at [your AddressFinder portal](https://portal.addressfinder.io/portal))
        * _Save_


#### Add Plugin to Record Page
* Goto _Setup_
    * select _Lightning App Builder_ -> _New_
    * select _Record Page_ -> _Next_
    * Fill in _Label_ and select the _Object_ (that has an address e.g. **User**)
    * Select _Clone Salesforce Default Page_ -> _Finish_
    * Type 'AddressFinder' into the search box
        * Click on _AddressFinder_ (under _Custom_)
        * Click _Activation_
            * Click _Org Default_ -> _Assign As Org Default_ -> _Close_
            * _Save_
    * PROFIT