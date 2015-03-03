B = B ? {}
window.B = B

require [
		'jquery'
		'b_dropdown'
	],
	($, Dropdown) ->

		initialize = () ->
			initBaseDropdownWithStaticHeader()
			initBaseDropdownWithDynamicHeader()

		initBaseDropdownWithStaticHeader = () ->
			B.baseDropdownStaticHeader = new Dropdown $('#baseDropdown-staticHeader'),
				staticHeaderText: "Base Dropdown"

		initBaseDropdownWithDynamicHeader = () ->
			B.baseDropdownDynamicHeader = new Dropdown $('#baseDropdown-dynamicHeader'),
				placeholderHeaderText: "Placeholder Text"

		#document ready
		$ () ->
		 initialize()
