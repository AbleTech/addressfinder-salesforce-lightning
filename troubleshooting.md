# Troubleshooting
We're sorry you're having problems but we promise we'll do our utmost to help you!  

To do that we need to work out what is going wrong. This may require a little bit of digging on your part but it should all be reasonably straightforward.

#### Initial Double-check
* Please double-check that the record page with which you're having problems is one to which you added the plugin as per [_Add Plugin_ section in the ReadMe](../blob/master/README.md#add-plugin-to-record-page)  
* And that the _edit pop-up for the record page_ above is open i.e. you've clicked the `edit` button and the editable screen is showing.  
(I know that you're pretty sure you have but please check, I've done this myself more than twice while writing this guide :disappointed: ).

***

Once you're satisfied that everything should be working, it's time to do some digging. :smile:

#### Prepare to Investigate
* Open the browser's _Developer Console_
    * _Right-click_ on the address component in the page
        * Select `Inspect`/`Inspect Element`
        
[![dev console video](screenshots/inspect_dev_console.png)](https://vimeo.com/224004039/f58379c017 "How to access the Developer Console")
        
        
The _Developer Console_ name may sound ominous but don't worry, you can't do anything wrong here. It's the equivalent of turning the light on in a dark room - it just lets you see what's going on.

***


## Look for errors
Firstly, let's make sure there are no errors or warnings for _AddressFinder_.
* In the _Developer Console_, select the tab called `Console`
    * Do a search for 'addressfinder'
        * Find the filter input box in the `Console` tab, type '**addressfinder**' into the filter and press `enter`
        
[![Address field error search video](screenshots/console_filter.png)](https://vimeo.com/224003546/5673741aa1 "Search for AddressFinder errors")
    
***Are there any errors or warnings showing?***  
_If there **are errors**_, copy and paste them into an email to us support@addressfinder.nz (but don't send it yet) then _skip the next (plugin) section_ and carry on with the sections following.

_If there are **no errors**_, carry on with the next section.

***

## Check the plugin is loaded
* In the _Developer Console_, look for a tab at the top titled `Inspector` or `Elements` (or one that has HTML in it - scroll to the top of the main panel and look for something like `<html lang="en">`)
* Press `ctrl-f` (Windows)/ `cmd-f` (Mac)
    * Type 'addressfinderwidget' into the _filter_ input box and press `enter`  
You should see a line highlighted (or part thereof) that looks similar to:
```
<script src="/resource/.../addressfinder__AddressFinderWidget" type="text/javascript"></script>
```

[![AddressFinderWidget video](screenshots/elements_widget.png)](https://vimeo.com/224003379/7b6c365af8 "Search for the AddressFinderWidget")

_If that line isn't there, it means that the widget hasn't been loaded on the page correctly._
* Check that the plugin is present on the page and that the page has been set as the _org default_.
    * Go back to the _Salesforce_ app.
    * Goto `Setup`
        * select `Lightning App Builder` -> `Edit` beside the record page you created (in the [_Add Plugin_ section in the ReadMe](../blob/master/README.md#add-plugin-to-record-page))
        * In the _Lightning App Builder_ record page:
            * Locate the _AddressFinder_ component in the record page (small blank section that, when you click on it, shows `Page - AddressFinder` in the top right of the screen)
            * Click `Save`
            * Click `Activation`.
                * In the `Org Default` tab, if there is a `Set as Org Default` button, click it.
                
_If that hasn't fixed it, carry on to the next section._

***

## Check the address fields
* Go back to the browser _Developer Console_ `Console` tab (as per the [_Look for errors_ section :point_up:](#check-the-plugin-is-loaded).
* Copy `document.querySelector('fieldset.forceInputAddress')`, paste this at the cursor arrow and press enter. 

    You should see a line highlighted (or part thereof) that looks similar to:
```
        <fieldset ... class="uiInput forceInputAddress uiInput--default uiInput--compound" ... >
```

[![Address element search video](screenshots/console_query_selector.png)](https://vimeo.com/224008905/a0c65c9432 "Search for the Address field elements")

_If that line isn't there_ (i.e. there is no `<fieldset>` element with a class of `forceInputAddress`), it's possible Salesforce have changed their default views and in turn broken our plugin. :sob: 
    
* So, if you can go back to the _Developer Console_ and find the HTML as per the [_Check the plugin is loaded_ section](#check-the-plugin-is-loaded)
    * _Right-click_ on the top HTML element e.g. `<html lang="en">`
    * `Copy` -> `Copy OuterHTML` 

    [![copy html video](screenshots/copy_html.png)](https://vimeo.com/224003533/0464ec6d0b "Copy html for support email")
    
    _This will copy the entire webpage which may include data that you may not want to pass on. If you're worried about that, you can paste the contents in a text editor and search & replace any sensitive text in the file with something obviously fake before you email it to us e.g._  
    ```
    <a href="mailto:sensitive.email@provider.com">sensitive.email@provider.com</a>
    ```
    
        becomes :arrow_down: 
        
    ```
    <a href="mailto:something.imaginary@ficticious.org">something.imaginary@ficticious.org</a>
    ```

