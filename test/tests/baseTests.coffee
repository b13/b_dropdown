module.exports =

	'Menu opens': (test) ->
		test
			.open 'http://localhost:7777'
			.click '#baseDropdown-staticHeader button'
			.assert.visible '#baseDropdown-staticHeader b_dropdown-menuWrap ul'
			.done()




