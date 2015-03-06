B = B ? {}
window.B = B

require [
		'jquery'
		'b_dropdown'
	],
	($, Dropdown) ->

		initialize = () ->
			initBasedDropdown()


		initBasedDropdown = () ->
			B.selectBasedDropdown = new Dropdown $('#selectDropdown'),
				placeholder: "Please select"


		#document ready
		$ () ->
		 initialize()
