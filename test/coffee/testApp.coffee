B = B ? {}

require [
		'jquery'
		'b_dropdown'
	],
	($, Dropdown) ->

		initialize = () ->
			initBaseDropdownWithStaticHeader()
			initBaseDropdownWithDynamicHeader()

		initBaseDropdownWithStaticHeader = () ->
			new Dropdown.BaseDropdown $('#baseDropdown-staticHeader'),
				staticHeaderText: "Base Dropdown"

		initBaseDropdownWithDynamicHeader = () ->
			new Dropdown.BaseDropdown $('#baseDropdown-dynamicHeader'),
				placeholderHeaderText: "Placeholder Text"

		#document ready
		$ () ->
		 initialize()
