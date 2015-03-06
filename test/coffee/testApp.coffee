B = B ? {}
window.B = B

require [
		'jquery'
		'b_dropdown'
	],
	($, Dropdown) ->

		initialize = () ->
			B.DropdownClass = Dropdown
			initBaseDropdown()


		initBaseDropdown = () ->
			B.selectBasedDropdown = new Dropdown $('#selectDropdown'),
				firstOptionIsPlaceholder: true
				selectedOption: 4


		#document ready
		$ () ->
		 initialize()
