define 'b_dropdown',
	[
		'jquery'
		'b_dropdown-option'
		'b_dropdown-base'
	],
	($, Option, BaseDropdown) ->

		return {
			Option       : Option
			BaseDropdown : BaseDropdown
		}