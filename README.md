# Administrator Setup

These are the steps for setting up the **AddressFinder** Salesforce Lightning Plugin.

It is assumed that the user performing these steps has _customization_ privileges for their Salesforce application. 

## Setup Steps
There are only **three** steps to setting the **AddressFinder** plugin correctly. 
* Firstly, install the **AddressFinder** plugin from the Lightning App Exchange as you would with any plugin.
* Secondly, add your **AddressFinder** account key as a record in the _AddressFinder Config Custom Setting_.
* [Lastly, add the **AddressFinder** plugin to any record pages with which you wish to use the **AddressFinder** service.](#Add-Plugin-to-Record-Page)


### Salesforce Admin Setup

#### Add Plugin to Record Page
* Goto _Setup_ -> _Lightning App Builder_ -> _New_
    * select _Record Page_ -> _Next_
    * Fill in _Label_ and select the _Object_ (that has an address e.g. **User**)
    * Select _Clone Salesforce Default Page_ -> _Finish_
    * Type 'AddressFinder' into the search box
        * Click on _AddressFinder_ (under _Custom_)
        * Click _Activation_
            * Click _Org Default_ -> _Assign As Org Default_ -> _Close_
            * _Save_
    * PROFIT