# AddressFinder Salesforce Lightning Plugin

## Development Environment Setup
1. Register as a Saleforce developer with dev account etc
1. Install [MavensMate](https://github.com/joeferraro/mavensmate-desktop) (Tested using latest [v0.0.11-beta.7](https://github.com/joeferraro/MavensMate-Desktop/releases/download/v0.0.11-beta.7/MavensMate-Desktop-0.0.11-beta.7.dmg) )
1. Set up local dev environment with either Atom or Sublime
1. Use MavensMate to open/create Project

### Atom Development Setup
Install [MavensMate for Atom](https://github.com/joeferraro/MavensMate-Atom). Either
* ```apm install MavensMate-Atom``` or
* Open Atom > _Preferences..._ > + _Install_ > _Search for "MavensMate"_ > _Install_

### Sublime Development Setup (not attempted)
See above but install [MavensMate for Sublime Text](https://github.com/joeferraro/MavensMate-SublimeText) 

## Salesforce Admin Setup
* Goto _Setup_ -> _Lightning App Builder_ -> _New_
    * select _Record Page_ -> _Next_
    * Fill in _Label_ and select _Object_ (that has an address)
    * Select _Clone Salesforce Default Page_ -> _Finish_
    * Type 'AddressFinder' into the search box
        * Click on _AddressFinder_ (under _Custom_)
        * Click _Activation_
            * Click _Org Default_ -> _Assign As Org Default_ -> _Close_
            * _Save_
  * PROFIT