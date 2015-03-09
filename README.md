# b_dropdown
Fully stylable javascript select menu.

## Introduction

b_dropdown is a small library that handles all your needs for creating custom drop down selections or menus. In general 
it can handle three different scenarios.
- HTML structure is provided
- HTML sctructure is provided as standard select option structure
- JSON data is provided


## Documentation

### Install with bower
	
	bower install https://github.com/b13/b_dropdown.git#v1.0.0 -S

### Base initialization with AMD

	require(['b_dropdown'], function(Dropdown){
	
    	var newDropdown = new Dropdown(selectElement, options);
    	
    });
    
#### Standard initialization based on a given select
In this case b_dropdown expects that there is already a html structure that is similar to the following:
	
##### Example select
	<select id="dropdownId" name="selectName">
		<option value="1">Option 1</option>
		<option value="2" disabled>Option 2</option>
		<option>Option 3</option>
		<option value="4" selected>Option 4</option>
		<option value="5">Option 5</option>
	</select>
	
##### Example js initialization code	

	require(['jquery','b_dropdown'], function($, Dropdown){
	
    	var newDropdown = new Dropdown($('#dropdownId'), { . . . });
    	
    });
    
##### Result HTML structure   
	<div class="mJS_dropdown m_dropdown" data-for="dropdownId">
		<button class="mJS_dropdown-toggle m_dropdown-toggle">
			Option 4
		</button>
		<div class="m_dropdown-menuWrap">
			<ul>
				<li data-value="1">                                
					Option 1 
				</li>
				<li data-value="2" class="m_dropdown-disabled"> 
					Option 2
				</li>
				<li>                                               
					Option 3 
				</li>
				<li data-value="4">                                
					Option 4 
				</li>
				<li data-value="5">                                  
					Option 5
				</li>
			</ul>
		</div>
	</div>
	<select id="dropdownId" name="selectName" class="m_dropdown-select">
		<option value="1">Option 1</option>
		<option value="2" disabled>Option 2</option>
		<option>Option 3</option>
		<option value="4" selected>Option 4</option>
		<option value="5">Option 5</option>
    </select>
    

    
### Settings

Option | Type | Default | Description
------ | ---- | ------- | ------------
disabled | boolean | false | Set this option to true if the dropdown should be disabled initially
firstOptionIsPlaceholder | boolean | false | The first select option will be treated as placeholder.
selectedOption | number | undefined | Index of the option that should be selected initially.
staticHeader | string | undefined | Static text stays in the header, even if an option is selected.

### Event handling

The handling of change event works basically in the same way as in a normal select. You can either simply 
bind change handlers to the select element itself or use the dropdowns onChange function. The advantage of 
the change function is, that all event handlers that was bound with this function get unbound if you call
the destroy function. Directly bound handlers won't be unbound automatically.

	var dropdown = new Dropdown ( ... );
	
	dropdown.onChange(function(event){
		//React to the option selection
	});

### Object types and functions

#### Dropdown Functions

Function name | Return value type | Description
------------- | ----------------- | -----------
closeMock() | Dropdown | Closes the mock menu and returns the dropdown object;
destroy() | undefined | Unbinds all change events that was bound with the onChange function, restores the state of the select structure and destroys the mock structure and the js object.
disable() | Dropdown | Disables the dropdown and returns its js object.
disableOption(*: indexElementOrOption) | Option | Disables an option and its mock pendant.
enable() | Dropdown | Enables the select and its mock pendant. Returns the Dropdown object.
enableOption(*: indexElementOrOption) | Enables an option and its mock pendant. Returns the enabled Option.
getLabelForOption(*: indexElementOrOption) | string/undefined | Returns the label of an option either based on its corresponding index, its HTML element or a jQuery collection that wraps the corresponding HTML element.
getOption(*: indexOrElement) | Option/undefined | Returns an option based on its order in the select structure.
getOptionByIndex(number: index) | Option/undefined | Returns the searche option based on its index.
getSelectedIndex() | number | Returns the index of the selected option.
getSelectedLabel() | string | Returns the text that is displayed in the option or an empty string.
getSelectedOption() | Option | Returns the selected option.
getSelectedValue() | string | Returns the value of the selected option.
getValueOfOption(*: indexElementOrOption) | string/undefined | Returns the value of an option either based on its corresponding index, its HTML element or a jQuery collection that wraps the corresponding HTML element.
isDisabled() | boolean | Returns true if the select is disabled.
isMockOpen() | boolean | Returns true if the mock menu is open.
offChange(function: changeHandler) | function/undefined | Unbinds handlers from the change event.
onChange(function: changeHandler) | function | Binds handlers to the change event.
openMock() | Dropdown | Opens the mock menu.
removeChangeHandlers() | array (The removed handlers) | Removes all handlers that where bound via the onChange function.
resetSelection() | Dropdown | Selects the first option, no matter if it is used as placeholder or not.
select(*: indexOrElement) | Option/undefined | Selects an option either based on its corresponding index, its HTML element or a jQuery collection that wraps the corresponding HTML element.
setLabelForOption(*: indexOrElement, string: label) | string/undefined | Sets the label for an option either based on its corresponding index, its HTML element or a jQuery collection that wraps the corresponding HTML element. Returns the label if set successfully or otherwise undefined.
setValueForOption(*: indexOrElement, string: value) | string/undefined | Sets the label for an option either based on its corresponding index, its HTML element or a jQuery collection that wraps the corresponding HTML element. Returns the value if set successfully or otherwise undefined.
toggleMock() | Dropdown | Toggles the open state of the mock menu.

#### Option Attributes

The following attributes get only updated if the change of them is triggered via a function in this documentation. 
Please make shure that these values get updated if you change them differently. An manual update can be achieved by 
setting the refresh attribute in the getters.

Attribute name | Type | Description
-------------- | ---- | -----------
$el | jQuery | jQuery collection that contains the options HTML element.
index | number | The index of the option.
label | string | The label value of the option.
value | string | Tha value of the option.


#### Option Functions

Function name | Return value type | Description
------------- | ----------------- | -----------
get$El() | jQuery | Returns a jQuery collection that contains the element that is represented by this option object.
getIndex(boolean: refresh) | number | Returns the index of the option. The value won't be updated automatically if you add or remove options. Please use the refresh option to force an update of the value.
getLabel(boolean: refresh) | string | Returns the label of the option. The value will only be updated if the setLabel function was used. In other cases please use the refresh option to force an update of the value.
getValue(boolean: refresh) | string | Returns the value of the option. The value will only be updated if the setValue function was used. In other cases please use the refresh option to force an update of the value.
setLabel(string: label) | string | Sets the text that will be displayed as option and returns it.
setValue(string: value) | string | Sets the value of the option and returns it.
isDisabled(refresh) | boolean | Returns true if the option is disabled. The value will only be updated if the functions of the Option or the Dropdown are used to enable or disable the option. In other cases use the refresh attribute to force an update of the value.
isSelected() | boolean | Return true if the option is selected. Otherwise false.