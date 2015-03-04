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
			initSelectBasedDropdown()


		initBaseDropdownWithStaticHeader = () ->
			B.baseDropdownStaticHeader = new Dropdown $('#baseDropdown-staticHeader'),
				staticHeader: "Base Dropdown"


		initBaseDropdownWithDynamicHeader = () ->
			B.baseDropdownDynamicHeader = new Dropdown $('#baseDropdown-dynamicHeader'),
				name: "overrodeTheOldName"
				placeholder: "Placeholder Text"


		initSelectBasedDropdown = () ->
			B.selectBasedDropdown = new Dropdown $('#selectDropdown'),
				placeholder: "Please select"


		#document ready
		$ () ->
		 initialize()
