# b_dropdown
Javascrip dropdown menu

## Introduction

b_dropdown is a small library that handles all your needs for creating custom drop down selections or menus. In general 
it can handle three different scenarios.
- HTML structure is provided
- HTML sctructure is provided as standard select option structure
- JSON data is provided


## Documentation

### Install with bower
	
	bower install https://github.com/b13/b_dropdown.git#v0.1.0 -S


### Base initialization with AMD

	require(['b_dropdown'], function(Dropdown){
	
    	var newDropdown = new Dropdown(htmlElement, options);
    	
    });
    
#### Initialization with provided HTML structure
In this case b_dropdown expects that there is already a html structure that is similar to the following:
	
##### HTML structure	
	<div id="dropdownId" class="b_dropdown">
		<button class="b_dropdown-toggle" type="button">Placeholder Text</button>
		<div class="b_dropdown-menuWrap">
			<ul>
				<li data-value="1">Option 1</li>
				<li data-value="2">Option 2</li>
				<li data-value="3">Option 3</li>
				<li data-value="4">Option 4</li>
				<li data-value="5">Option 5</li>
			</ul>
		</div>
		<form>
			<input type="hidden">
		</form>
	</div>
	
##### Example js initialization code	

	require(['jquery','b_dropdown'], function($, Dropdown){
	
    	var newDropdown = new Dropdown($('#dropdownId'), { . . . });
    	
    });
    
    
#### Initialization with provided select HTML structure 

##### Example Source HTML structure	
	<select id="dropdownId">
		<option value="1">Option 1</option>
		<option value="2">Option 2</option>
		<option value="3">Option 3</option>
		<option value="4">Option 4</option>
		<option value="5">Option 5</option>
	</select>
	
##### Example js initialization code	

	require(['jquery','b_dropdown'], function($, Dropdown){
	
    	var newDropdown = new Dropdown($('#dropdownId'), { . . . });
    	
    });


#### Initialization with provided JSON data

##### Example Source HTML structure	
	<div id="dropdownId">
	</div>
	
##### Example js initialization code	

	require(['jquery','b_dropdown'], function($, Dropdown){
	
    	var newDropdown = new Dropdown($('#dropdownId'), {
    		options: [
    			{ label: 'Option 1', value: '1' }
    			{ label: 'Option 2', value: '2' }
    			{ label: 'Option 3', value: '3' }
    			{ label: 'Option 4', value: '4' }
    			{ label: 'Option 5', value: '5' }
    		]
    	});
    	
    });
    

### Settings

Option | Type | Default | Description
------ | ---- | ------- | ------------
useFirstOptionAsPlaceholder | false | The first select option will be treated as placeholder.
placeholder | string | undefined | Header text that is displayed if no option is selected.
selectedOption | number | undefined | Index of the option that should be selected initially.
staticHeader | string | undefined | Static text stays in the header, even if an option is selected.

### Event handling

It is possible to use the onSelectOption function to register handlers that react on option selections.

	var dropdown = new Dropdown ( ... );
	
	dropdown.onSelectOption(function(eventObject){
		//React on the option selection
	});
	
The	eventObject that will be provided to the handler will look similar to this:

	{
		dropdown : dropdownObject // Reference to the dropdown object
		option   : optionObject   // Reference to the option object
		timestamp: currentTime    // Date object with that represents the time the event was fired
	}

To learn more about the option object, please have a look down at the Option section.

### Object types and functions

#### Dropdown Definition

##### Functions

Function name | Return value type | Description
------------- | ----------------- | -----------
close() | Dropdown | Closes the dropdown and returns the dropdown object;
destroy() | undefined | Unbinds all dropdown events and destroys the js object.
disable() | Dropdown | Disables the dropdown and returns it.
enable() | Dropdown | Enables the dropdown and returns it.
getOption(various: indexOrElement) | Option/undefined | Returns the searched option object.<br>It expects one of the following:<br>number: optionIndex<br>Option: the option itself<br>jQuery: a jQuery object that wraps the objects HTML element<br>HTMLElement: the objects HTMLElement
getOptionByIndex(number: index) | Option/undefined | Returns the searche option based on its index.
getSelectedIndex() | number | Returns either the index of the selected option or -1.
getSelectedLabel() | string/undefined | Returns the label of the selected option or undefined.
getSelectedOption() | Option/undefined | Returns the selected option ir undefined.
getSelectedValue() | string/undefined | Returns the value of the selected option or undefined.
isDisabled() | boolean | Returns true if the dropdown is disabled or false otherwise.
isOpen() | boolean | Returns true if the dropdown is open.
offChange(function: changeHandler) | function/undefined | Unregisteres the provided handler function and returns it if it was actually unregistered.
onChange(function: changeHandler) | function | Registers a handler that gets called if the selected value changes and returns it.
open() | Dropdown | Opens the dropdown and returns it. 
removeAllHandlers() | array (The removed handlers) | Removes all option selection handler and returns them.
resetSelection() | Dropdown | Resets the dropdown value. Returns the dropdown.
select(various: indexOrElement, boolean: preventEvent) | Option/undefined | Selects an option and returns it or undefined.
toggle() | Dropdown | Opens the dropdown if it's closed, or closes it if it's open. Returns the dropdown object.

#### Option Definition

##### Attributes

Attribute name | Type | Description
-------------- | ---- | -----------
$el | jQuery | jQuery collection that contains the options HTML element.
index | number | The index of the option.
label | string | The label value of the option.
value | string | Tha value of the option.


##### Functions

Function name | Return value type | Description
------------- | ----------------- | -----------
get$El() | jQuery | Returns a jQuery collection that contains the element that is represented by this option object.
getIndex() | number | Returns the index of the option.
getLabel() | string | Returns the label of the option.
getValue() | string | Returns the value of the option.

