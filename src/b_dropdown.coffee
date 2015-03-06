define 'b_dropdown',
	['jquery'],
	($) ->


		class Dropdown

			defaultOpts:
				disabled                 : undefined
				firstOptionIsPlaceholder : false
				hideOriginalSelect       : true


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
				@$mockEl = $ '<div class="bJS_md_dropdown b_md_dropdown"></div>'
				@$selectEl.before @$mockEl

				# Add b_md_dropdown styling class to the select element
				@$selectEl.addClass 'b_md_dropdown-select'

				# Render the mock structure based on the extracted information from the select structure
				@_renderMockHTMLFromData @$mockEl, renderData

				# Get jQuery collections that wrap important HTML elements of the mock structure
				@$mockToggleHeader = @$mockEl.find '.bJS_md_dropdown-toggle'
				@$mockMenu         = @$mockEl.find 'ul'
				@$mockOptions      = @$mockMenu.children 'li'

				# Init data object, that saves the state of the dropdown
				@data =
					isMockOpen : false
					isDisabled : false
					ddOptions  : @_initDropdownOptions()

				# Array in which the b_md_dropdown change handlers will be stored
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
			_renderMockHTMLFromData:
			Renders the mock structure based on information that was extracted from the select structure

			@param $targetEl
			@param @renderData
			###
			_renderMockHTMLFromData: ($targetEl, renderData) ->

				$targetEl.append $ '<button class="bJS_md_dropdown-toggle b_md_dropdown-toggle"></button>'

				$mockMenuWrap = $ '<div class="b_md_dropdown-menuWrap"></div>'
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
						$newOptionEl.addClass 'b_md_dropdown-disabled'

					if i is 0 and	@opts.firstOptionIsPlaceholder
						$newOptionEl.addClass 'b_md_dropdown-placeholder'

				return $targetEl

			###
			_getRenderDataFromSelectStructure:
			Extract json data form a given html select-option structure

			@param $selectElement
			@returns {{options: Array}}
			@private
			###
			_getRenderDataFromSelectStructure: ($selectElement) ->
				renderData =
					options: []

				$optionsEls = $selectElement.children 'option'
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


			_initDropdownOptions: () ->
				dropddown = @
				ddOptions = []

				@$realOptions.each ()->
					ddOptions.push new Option dropddown, @

				return ddOptions;


			_bindEvents: () ->
				@$mockToggleHeader.on 'click', @_handleToggleBtnClick
				@$mockOptions.on 'click', @_handleMockOptionSelection
				@$selectEl.on 'change', @_handleChange
				$(window).on 'click', @_handleWindowClick


			_handleMockOptionSelection: (evt) =>
				@select @$mockOptions.index $ evt.currentTarget
				@closeMock()


			_handleChange: () =>
				option = @_updateSelect @$realOptions.filter(':selected'), false, true, false, true
				if option and not option.isDisabled()
					@closeMock()


			_handleToggleBtnClick: (evt) =>
				evt.preventDefault()
				@toggleMock()


			_handleWindowClick: (evt) =>
				if not @isDisabled() and @isMockOpen() and not $.contains @$mockEl.get(0), evt.target
					@closeMock()


			_unbindEvents: () ->
				@$mockToggleHeader.off 'click', @_handleToggleBtnClick
				@$mockOptions.off 'click', @_handleMockOptionSelection
				@$selectEl.off 'change', @_handleChange
				$(window).off 'click', @_handleWindowClick


			_updateSelect: (indexOrElement, updateSelect, updateMock, triggerChange, callChangeHandlers) ->
				option = @getOption indexOrElement
				timestamp = new Date()

				if option and not option.isDisabled()
					@data.selectedOption = option

					if updateSelect
						option.$realEl.prop 'selected', true

					if updateMock
						@$mockToggleHeader.text option.getLabel()

					if triggerChange
						@$selectEl.trigger 'change'

					if callChangeHandlers
						for changeHandler in @changeHandlers
							changeHandler.call @,
								dropdown : @
								option   : option
								timestamp: timestamp

				return option


			closeMock: () =>
				if not @isDisabled()
					@$mockEl.removeClass 'b_md_dropdown-open'
					@data.isMockOpen = false

				return @


			destroy: () ->
				# Clean up HTML structure
				@$selectEl.removeClass 'b_md_dropdown-select'
				@$mockEl.remove()

				# Remove event bindings
				@_unbindEvents()

				# Delete this object
				delete @
				return undefined


			disable: () ->
				@closeMock()
				@$selectEl.prop 'disabled', true
				@$mockEl.addClass 'b_md_dropdown-disabled'
				@data.isDisabled = true
				return @

			disableOption: (indexOrElement)	->
				option = @getOption indexOrElement
				if option then option.disable()

				return option


			enable: () ->
				@$selectEl.prop 'disabled', false
				@$mockEl.removeClass 'b_md_dropdown-disabled'
				@data.isDisabled = false
				return @;


			enableOption: (indexOrElement) ->
				option = @getOption indexOrElement
				if option then option.enable()

				return option


			getOption: (indexOrElement) ->

				if indexOrElement instanceof Option
					index = @data.ddOptions.indexOf indexOrElement

				else if indexOrElement instanceof $
					$el = indexOrElement

				else if indexOrElement instanceof HTMLElement
					$el = $ indexOrElement

				else if typeof indexOrElement is 'number'
					index = indexOrElement

				else
					throw "Provided argument is neither a html element nor a number"

				if $el
					index = @$realOptions.index $el

				return @getOptionByIndex index


			getOptionByIndex: (optionIndex) ->
				return if @data.ddOptions.length > optionIndex then @data.ddOptions[optionIndex] else undefined


			getSelectedIndex: () ->
				selectedOption = @getSelectedOption()
				return if selectedOption then selectedOption.getIndex() else -1


			getSelectedLabel: () ->
				selectedOption = @getSelectedOption()
				return if selectedOption then selectedOption.getLabel() else undefined


			getSelectedOption: () ->
				return @data.selectedOption or undefined


			getSelectedValue: () ->
				selectedOption = @getSelectedOption()
				return if selectedOption then selectedOption.getValue() else undefined


			isDisabled: () ->
				return @data.isDisabled


			isMockOpen: () ->
				return @data.isMockOpen or false


			offChange: (changeHandler) ->
				handlerIndex = @changeHandlers.indexOf changeHandler

				if handlerIndex >= 0
					@changeHandlers.splice handlerIndex, 1
					return changeHandler

				return undefined


			onChange: (changeHandler) ->
				@changeHandlers.push changeHandler
				return changeHandler


			openMock: () =>
				if not @isDisabled()
					@$mockEl.addClass 'b_md_dropdown-open'
					@data.isMockOpen = true
				return @


			removeAllHandlers: () ->
				removedHandlers = @changeHandlers
				@changeHandlers = []
				return removedHandlers


			resetSelection: () =>
				return @select 0


			select: (indexOrElement) =>
				return @_updateSelect indexOrElement, true, true, true, true


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


			disable: () ->
				@disabled = true
				@$realEl.prop 'disabled', true
				@$mockEl.addClass 'b_md_dropdown-disabled'


			enable: () ->
				@disabled = false
				@$realEl.prop 'disabled', false
				@$mockEl.removeClass 'b_md_dropdown-disabled'


			get$RealEl: () ->
				return @$realEl


			get$MockEl: () ->
				return @$mockEl


			getIndex: () ->
				if not @index?
					@index = @dropdown.$realOptions.index @$realEl

				return @index


			getLabel: (refresh) ->
				if refresh or not @label?
					@label = @$realEl.text()
				return @label


			getValue: (refresh) ->
				if refresh or not @value?
					@value = @$realEl.val() or ""

				return @value


			isDisabled: (refresh) ->
				if refresh or not @disabled?
					@disabled = @$realEl.prop 'disabled'
				return @disabled


		return Dropdown