# b_dropdown
Javascrip dropdown menu

## Introduction

b_dropdown is a small library that handles all your needs for creating custom drop down selections or menus. In general 
it can handle three different scenarios.
- HTML structure is provided
- HTML sctructure is provided as standard select option structure
- JSON data is provided


## Documentation

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
closeOnSelect | boolean | true | Menu will be closed on option selection
options | array | undefined | Array with option definitions. An option can be either a string, in this case the string is used as label and value, or a object that contains at least a value field and optionally a label field.<br>Examples:<br>["Option 1", "Option2", . . . ]<br><br>[<br>{ label: 'Option 1', value: '1' }<br>{ label: 'Option 2', value: '2' }<br> . . . ]
placeholder | string | undefined | Header text that is displayed if no option is selected
selectedOption | number | undefined | Index of the option that should be selected initially
staticHeader | string | undefined | Static text stays in the header, even if an option is selected

### Events



### Functions

	closeOnSelect


