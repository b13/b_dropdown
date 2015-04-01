define 'b_dropdown',
	['jquery'],
	($) ->


		class Dropdown

			defaultOpts:
				disabled                 : undefined
				firstOptionIsPlaceholder : false
				hideOriginalSelect       : true


			###
  		@param $parentEl
      @param JSONData
      @param opts
      @return {Dropdown}

  		Renders a HTML select structure based on given JSON data, inserts it into the given $parentEl and creates a new
  		Dropdown based on the rendered select structure.
  		###
			@createDropdownFromJSON: ($parentEl, JSONData, opts) ->
				$selectEl = @_renderSelectFromJSON $parentEl, JSONData
				return new Dropdown $selectEl, opts


			###
  		@param $parentEl
      @param JSONData
  		@return {jQuery}

  		Renders a HTML select structure based on given JSON data, inserts it into the given $parentEl.
  		###
			@_renderSelectFromJSON: ($parentEl, JSONData) ->
				$selectEl = $ '<select></select>'
				$parentEl.append $selectEl

				if JSONData.name then $selectEl.attr 'name', JSONData.name

				for option in JSONData.options
					$newOption = $ '<option></option>'
					$selectEl.append $newOption
					if option.value then $newOption.val option.value
					if option.disabled then $newOption.prop 'disabled', true
					if option.label then $newOption.text option.label

				return $selectEl


			constructor: (el, opts) ->
				@$selectEl = $ el
				@$realOptions = @$selectEl.children 'option'

				@opts = $.extend {}, @defaultOpts, opts or {}


				# Throw error if the provided element is no select HTML element
				if @$selectEl.prop('tagName') isnt 'SELECT'
					throw "The provided HTML element is no <select> element"

				# Get render information for the mock structure from the select structure
				renderData = @_getRenderDataFromSelectStructure @$selectEl

				# Get the selected option index from the select structure if no selected option index is set in the opts
				if not @opts.selectedOption and renderData.selectedOption?
					@opts.selectedOption = renderData.selectedOption

				# Set the top element of the mock structure
				@$mockEl = $ '<div class="mJS_dropdown m_dropdown"></div>'
				@$selectEl.before @$mockEl

				# Add m_dropdown styling class to the select element
				@$selectEl.addClass 'm_dropdown-select'

				# Render the mock structure based on the extracted information from the select structure
				@_renderMockHTMLFromData @$mockEl, renderData

				# Get jQuery collections that wrap important HTML elements of the mock structure
				@$mockToggleHeader = @$mockEl.find '.mJS_dropdown-toggle'
				@$mockMenu         = @$mockEl.find 'ul'
				@$mockOptions      = @$mockMenu.children 'li'

				# Init data object, that saves the state of the dropdown
				@data =
					isMockOpen : false
					isDisabled : false
					ddOptions  : @_initDropdownOptions()

				# Array in which the m_dropdown change handlers will be stored
				@changeHandlers = []

				# Set static header to mock header if provided
				if @opts.staticHeader
					@$mockToggleHeader.html '<span>' + @opts.staticHeader + '</span>'

				# - - - - - - - - - - - - - - - - - - - - - - #
  			#	Trigger functions to update mock correctly
				# - - - - - - - - - - - - - - - - - - - - - - #

				# Select initial option if provided or the first option
				if @opts.selectedOption? and @opts.selectedOption >= 0
					@select @opts.selectedOption, true
				else
					@select 0, true


				# Disable select if opts disabled is true
				if @opts.disabled is false
					@enable()
				else if @opts.disabled or @$selectEl.prop 'disabled'
					@disable()


				# Bind all events
				@_bindEvents()

			###
  		@param $targetEl
      @param renderData
      @return {jQuery}
      @private

			Renders the mock structure based on information that was extracted from the select structure
			###
			_renderMockHTMLFromData: ($targetEl, renderData) ->

				if renderData.selectId then $targetEl.data 'for', renderData.selectId

				$targetEl.append $ '<button class="mJS_dropdown-toggle m_dropdown-toggle"></button>'

				$mockMenuWrap = $ '<div class="m_dropdown-menuWrap"></div>'
				$targetEl.append $mockMenuWrap

				$mockMenu = $ '<ul></ul>'
				$mockMenuWrap.append $mockMenu

				for option, i in renderData.options
					if typeof option is 'string'
						label = option
						value = option
					else
						value = option.value
						label = option.label or value

					$newOptionEl = $ '<li data-value="' + value + '"></li>'
					$mockMenu.append $newOptionEl

					$newOptionEl.text label
					if option.disabled
						$newOptionEl.addClass 'm_dropdown-disabled'

					if i is 0 and	@opts.firstOptionIsPlaceholder
						$newOptionEl.addClass 'm_dropdown-placeholder'

				return $targetEl

			###
			@param $selectElement
			@return {{options: Array}}
			@private

  		Gets information from the select about how the mock structure must be rendered.
			###
			_getRenderDataFromSelectStructure: ($selectElement) ->
				renderData =
					options: []

				selectId = $selectElement.attr 'id'
				if selectId then renderData.selectId = renderData

				$optionsEls = $selectElement.children 'option'

				#Extract information from each option
				$optionsEls.each (index) ->
					nextOptionObject = {}
					$option = $ @
					nextOptionObject.label    = $option.text() or ""
					nextOptionObject.value    = $option.val() or nextOptionObject.label
					nextOptionObject.disabled = $option.prop 'disabled'
					nextOptionObject.selected = $option.prop 'selected'
					if nextOptionObject.selected
						renderData.selectedOption = index

					renderData.options.push nextOptionObject

				return renderData

			###
			return {Array}
  		@private

  		Initializes the option objects that will be used to manage the dropdowns state.
			###
			_initDropdownOptions: () ->
				dropddown = @
				ddOptions = []

				@$realOptions.each ()->
					ddOptions.push new Option dropddown, @

				return ddOptions;


			###
  		return {Dropdown}
  		@private

  		Binds the needed event handlers to DOM events.
			###
			_bindEvents: () ->
				@$mockToggleHeader.on 'click', @_handleToggleBtnClick
				@$mockOptions.on 'click', @_handleMockOptionSelection
				@$selectEl.on 'change', @_handleChange
				$(window).on 'click', @_handleWindowClick
				return @


			###
  		@param evt
  		@return {void 0}
  		@private

  		Handler for the click event on mock option HTML elements.
  		Calls an update on the dropdown.
			###
			_handleMockOptionSelection: (evt) =>
				@select @$mockOptions.index $ evt.currentTarget
				@closeMock()
				return undefined


			###
  		@return {void 0}
  		@private

  		Handler for the select element change event.
  		Calls an update on the dropdown.
			###
			_handleChange: () =>
				option = @_updateSelect @$realOptions.filter(':selected'), false, true, false, true
				if option and not option.isDisabled()
					@closeMock()
				return undefined


			###
  		@param evt
  		@return {void 0}
  		@private

  		Handler for the click event on the header button of the mock structure.
  		Toggles the mocks open state.
			###
			_handleToggleBtnClick: (evt) =>
				evt.preventDefault()
				@toggleMock()
				return undefined


			###
  		@param evt
  		@private

  		Handler that will be bound to the windows click event.
  		Calls close if the click was outside the select and outside the mock.
			###
			_handleWindowClick: (evt) =>
				if not @isDisabled() and @isMockOpen() and not $.contains @$mockEl.get(0), evt.target
					@closeMock()
				return undefined


			###
  		@return {Dropdown}
  		@private

  		Unbinds all handlers that was bound on _bindEvents() from their events.
			###
			_unbindEvents: () ->
				@$mockToggleHeader.off 'click', @_handleToggleBtnClick
				@$mockOptions.off 'click', @_handleMockOptionSelection
				@$selectEl.off 'change', @_handleChange
				$(window).off 'click', @_handleWindowClick
				@removeChangeHandlers()
				return @


			###
  		@param indexElementOrOption
  		@param updateSelect
  		@param updateMock
  		@param triggerChange
  		@param callChangeHandlers
  		@return {Option}
  		@private

  		Private helper function that is essentially for the state and view update of the dropdown.
			###
			_updateSelect: (indexElementOrOption, updateSelect, updateMock, triggerChange) ->
				option = @getOption indexElementOrOption
				timestamp = new Date()

				if option and not option.isDisabled()
					@data.selectedOption = option

					if updateSelect
						option.$realEl.prop 'selected', true

					if updateMock
						@$mockToggleHeader.text option.getLabel()

					if triggerChange
						@$selectEl.trigger 'change'

				return option


			###
			@return {Dropdown}

  		Closes the mock menu.
			###
			closeMock: () =>
				if not @isDisabled()
					@$mockEl.removeClass 'm_dropdown-open'
					@data.isMockOpen = false

				return @


			###
  		@return {void 0}

  		Destroys the dropdown. That means:
  		- Removing b_dropdown specific css classes.
  		- Destroying the mock structure.
  		- Unbinding all b_dropdown event handlers.
			###
			destroy: () ->
				# Clean up HTML structure
				@$selectEl.removeClass 'm_dropdown-select'
				@$mockEl.remove()

				# Remove event bindings
				@_unbindEvents()

				# Delete this object
				delete @
				return undefined


			###
  		@return {Dropdown}

  		Sets the select as disabled and emulates a similar behaviour for the mock.
			###
			disable: () ->
				@closeMock()
				@$selectEl.prop 'disabled', true
				@$mockEl.addClass 'm_dropdown-disabled'
				@data.isDisabled = true
				return @


			###
  		@param indexElementOrOption
  		@return {Option}

  		Disables an option and its mock pendant.
			###
			disableOption: (indexElementOrOption)	->
				option = @getOption indexElementOrOption
				if option then option.disable()

				return option


			###
  		@return {Dropdown}

  		Enables the select and its mock pendant.
			###
			enable: () ->
				@$selectEl.prop 'disabled', false
				@$mockEl.removeClass 'm_dropdown-disabled'
				@data.isDisabled = false
				return @;


			###
  		@param indexElementOrOption
  		@return {Option}

  		Enables an option and its mock pendant.
			###
			enableOption: (indexElementOrOption) ->
				option = @getOption indexElementOrOption
				if option then option.enable()

				return option


			###
  		@return {string}

  		Returns the label of an option either based on its corresponding index, its HTML element or a jQuery collection that wraps
  		the corresponding HTML element.
  		###
			getLabelForOption: (indexElementOrOption) ->
				option = @getOption indexElementOrOption
				if option
					return option.getLabel()
				return undefined


			###
  		@param indexElementOrOption
  		@return {Option}

  		Returns an option either based on its corresponding index, its HTML element or a jQuery collection that wraps
  		the corresponding HTML element.
			###
			getOption: (indexElementOrOption) ->

				if indexElementOrOption instanceof Option
					index = @data.ddOptions.indexOf indexElementOrOption

				else if indexElementOrOption instanceof $
					$el = indexElementOrOption

				else if indexElementOrOption instanceof HTMLElement
					$el = $ indexElementOrOption

				else if typeof indexElementOrOption is 'number'
					index = indexElementOrOption

				else
					throw "Provided argument is neither a html element nor a number"

				if $el
					index = @$realOptions.index $el

				return @getOptionByIndex index


			###
  		@param optionIndex
  		@return {Option}

  		Returns an option based on its order in the select structure.
			###
			getOptionByIndex: (optionIndex) ->
				return if @data.ddOptions.length > optionIndex then @data.ddOptions[optionIndex] else undefined


			###
  		@return {number}

  		Returns the index of the selected option.
			###
			getSelectedIndex: () ->
				selectedOption = @getSelectedOption()
				return if selectedOption then selectedOption.getIndex() else 0


			###
  		@return {string}

  		Returns the text that is displayed in the option or an empty string.
			###
			getSelectedLabel: () ->
				selectedOption = @getSelectedOption()
				return if selectedOption then selectedOption.getLabel() else ""


			###
  		@return {Option}

  		Returns the Option object of the selected option.
			###
			getSelectedOption: () ->
				return @data.selectedOption or @getOptionByIndex 0


			###
  		@return {*}

  		Returns the value of the selected option.
			###
			getSelectedValue: () ->
				selectedOption = @getSelectedOption()
				return if selectedOption then selectedOption.getValue() else undefined


			###
			@return {string}

			Returns the value of an option either based on its corresponding index, its HTML element or a jQuery collection that wraps
			the corresponding HTML element.
			###
			getValueOfOption: (indexElementOrOption) ->
				option = @getOption indexElementOrOption
				if option
					return option.getValue()
				return undefined


			###
  		@return {boolean}

  		Returns true if the select is disabled.
			###
			isDisabled: () ->
				return @data.isDisabled


			###
  		@return {boolean}

  		Returns true if the mock menu is open.
			###
			isMockOpen: () ->
				return @data.isMockOpen or false


			###
  		@param changeHandler

  		Unbinds handlers from the change event.
			###
			offChange: (changeHandler) ->
				handlerIndex = @changeHandlers.indexOf changeHandler

				@$selectEl.off 'change', changeHandler
				if handlerIndex >= 0
					@changeHandlers.splice handlerIndex, 1
					return changeHandler

				return undefined

			###
			@param changeHandler

			Binds handlers to the change event.
			###
			onChange: (changeHandler) ->
				@changeHandlers.push changeHandler
				@$selectEl.on 'change', changeHandler
				return changeHandler


			###
  		@return {Dropdown}

  		Opens the mock menu.
			###	
			openMock: () =>
				if not @isDisabled()
					@$mockEl.addClass 'm_dropdown-open'
					@data.isMockOpen = true
				return @


			###
  		@return {Array}

  		Removes all handlers that where bound via the onChange function.
			###
			removeChangeHandlers: () ->
				for changeHandler in @changeHandlers
					@offChange changeHandler
				removedHandlers = @changeHandlers
				@changeHandlers = []
				return removedHandlers


			###
  		@return {Option}

  		Selects the first option, no matter if it is used as placeholder or not.
			###
			resetSelection: () =>
				return @select 0


			###
  		@return {Option}

  		Selects an option either based on its corresponding index, its HTML element or a jQuery collection that wraps
  		the corresponding HTML element.
			###
			select: (indexElementOrOption) =>
				return @_updateSelect indexElementOrOption, true, true, true, true
				

			selectOptionByValue: (value) =>
				for option in @data.ddOptions
					if `option.getValue() == value`
						return @select option

				return undefined


			###
  		@return {string}

  		Sets the label for an option either based on its corresponding index, its HTML element or a jQuery collection that wraps
  		the corresponding HTML element.
  		###
			setLabelForOption: (indexElementOrOption, label) ->
				option = @getOption indexElementOrOption
				if option
					return option.setLabel label
				return undefined

			###
			@return {string}

			Sets the value for an option either based on its corresponding index, its HTML element or a jQuery collection that wraps
			the corresponding HTML element.
			###
			setValueForOption: (indexElementOrOption, value) ->
				option = @getOption indexElementOrOption
				if option
					return option.setValue value
				return undefined


			###
  		@return {Dropdown}

  		Toggles the open state of the mock menu.
			###
			toggleMock: () =>
				if @isMockOpen() then @closeMock() else @openMock()
				return @


		# Private dropdown option helper class
		class Option

			constructor: (dropdown, option) ->
				@dropdown = dropdown

				if option instanceof Option
					@$realEl = option.$realEl

				else if option instanceof $
					@$realEl = option.eq 0

				else if option instanceof HTMLElement
					@$realEl = $ option

				else if typeof option is 'number'
					@index = option
					@$realEl = @dropdown.$realOptions.eq option

				else
					throw "Provided argument is neither a html element nor a number"

				if not @index? then @index = @dropdown.$realOptions.index @$realEl
				@$mockEl  = @dropdown.$mockOptions.eq @index
				@isDisabled()
				@getLabel()
				@getValue()


			###
  		@return {Option}

  		Disables the option and its views.
			###
			disable: () ->
				@disabled = true
				@$realEl.prop 'disabled', true
				@$mockEl.addClass 'm_dropdown-disabled'
				return @


			###
  		@return {Option}

  		Enables the option and its views.
			###
			enable: () ->
				@disabled = false
				@$realEl.prop 'disabled', false
				@$mockEl.removeClass 'm_dropdown-disabled'
				return @


			###
  		@return {jQuery}

  		Returns the corresponding <option> HTML element of the option, wrapped in a jQuery collection.
			###
			get$RealEl: () ->
				return @$realEl


			###
			@return {jQuery}

			Returns the corresponding mock HTML element of the option, wrapped in a jQuery collection.
			###
			get$MockEl: () ->
				return @$mockEl


			###
  		@return {number}

  		Returns the index of the option.
			###
			getIndex: (refresh) ->
				if refresh or not @index?
					@index = @dropdown.$realOptions.index @$realEl

				return @index


			###
  		@return {string}

  		Returns the text that is visible in the option, if available.
			###
			getLabel: (refresh) ->
				if refresh or not @label?
					@label = @$realEl.text()
				return @label


			###
  		@return {string}

  		Returns the value of the option, if available.
			###
			getValue: (refresh) ->
				if refresh or not @value?
					@value = @$realEl.val() or ""

				return @value


			###
  		@return {string}

  		Sets the text that will be displayed as option.
  		###
			setLabel: (label) ->
				@label = label
				@$realEl.text label
				@$mockEl.text label
				if @isSelected()
					@dropdown.$mockToggleHeader.text label
				return label


			###
  		@return {string}

  		Sets the value of the option.
  		###
			setValue: (value) ->
				@value = value
				@$realEl.val value
				return value

			###
  		@return {boolean}

  		Returns true if the option is disabled. Otherwise false.
			###
			isDisabled: (refresh) ->
				if refresh or not @disabled?
					@disabled = @$realEl.prop 'disabled'
				return @disabled


			###
  		@return {boolean}

  		Return true if the option is selected. Otherwise false.
			###
			isSelected: () ->
				return @$realEl.prop 'selected'


		return Dropdown