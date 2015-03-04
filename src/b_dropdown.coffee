define 'b_dropdown',
	['jquery'],
	($) ->


		class Dropdown

			defaultOpts:
				closeOnClickOutside: true
				closeOnSelect: true

			constructor: (el, opts) ->

				$el = $ el
				isWrappedByForm = Boolean $el.closest('form').length

				@opts = $.extend {}, @defaultOpts, opts or {}
				
				if @opts.options
					jSONOptions = @opts.options

				if $el.prop('tagName') is 'SELECT'
					attrs = $el.prop 'attributes'
					if not @opts.name then @opts.name  = $el.attr 'name'

					if not jSONOptions then jSONOptions = @_getJSONDataFromSelectStructure $el

					$replacement = $ '<div></div>'
					$el.after $replacement
					$el.remove()
					$el = $replacement

					__setElementAttribute $el, attribute for attribute in attrs

					$el.addClass 'b_dropdown'


				if jSONOptions
					$el.empty()
					@_renderInnerHTMLFromJSON $el, jSONOptions, isWrappedByForm

				@$el = $el

				if not @$toggleHeader then @$toggleHeader = @$el.find '.b_dropdown-toggle'
				if not @$menu         then @$menu         = @$el.find 'ul'
				if not @$options      then @$options      = @$menu.children 'li'
				if not @$hiddenInput  then @$hiddenInput  = @$el.find 'input[type=hidden]'

				if @opts.name then @$hiddenInput.attr 'name', @opts.name

				@selectionHandlers = []

				@data =
					isOpen    : false
					isDisabled: false
					ddOptions   : @_initDropdownOptions()

				# Set static header if provided
				if @opts.staticHeader
					@$toggleHeader.html '<span>' + @opts.staticHeader + '</span>'

				# Select initial option if provided or close the menu
				if @opts.selectedOption? and @opts.selectedOption >= 0
					@select @opts.selectedOption
				else
					@select -1

				@bindEvents()


			_renderInnerHTMLFromJSON: ($targetEl, jSONOptions, isWrappedByForm) ->

				@toggleHeader = $ '<button class="b_dropdown-toggle"></button>'
				$targetEl.append @toggleHeader

				$menuWrap = $ '<div class="b_dropdown-menuWrap"></div>'
				$targetEl.append $menuWrap

				@$menu = $ '<ul></ul>'
				$menuWrap.append @$menu

				for option in jSONOptions
					if typeof option is 'string'
						label = option
						value = option
					else
						value = option.value
						label = option.label or value
						isLink = option.isLink or false

					$newOptionEl = $ '<li data-value="' + value + '"></li>'
					@$menu.append $newOptionEl

					if isLink
						$newLink = $ '<a href="' + (option.href or "") + '"></a>'
						$newOptionEl.append $newLink

					$newOptionEl.text label

				@$hiddenInput = $ '<input type="hidden"></input>'
				$targetEl.append @$hiddenInput

				if isWrappedByForm then @$hiddenInput.wrap '<form></form>'


				#Extract json data form a given html select-option structure
			_getJSONDataFromSelectStructure: ($selectElement) ->
				optionsArray = []
				$optionsEls = $selectElement.children 'option'
				$optionsEls.each () ->
					nextOptionObject = {}
					$option = $ @
					$link   = $option.children 'a'
					nextOptionObject.label   = $option.text() or ""
					nextOptionObject.value   = $option.val() or nextOptionObject.label

					if $link.length
						nextOptionObject.isLink = true
						nextOptionObject.href = $link.attr 'href'

					optionsArray.push nextOptionObject

				return optionsArray


			_initDropdownOptions: () ->
				dropddown = @
				ddOptions = []

				@$options.each ()->
					ddOptions.push new Option dropddown, @

				return ddOptions;


			bindEvents: () ->
				@$toggleHeader.on 'click', @toggle
				@$options.on 'click', @_handleOptionSelection
				$(window).on 'click', @_handleWindowClick


			unbindEvents: () ->
				@$toggleHeader.off 'click', @toggle
				$(window).off 'click', @_handleWindowClick


			_handleOptionSelection: (evt) =>
				if not @isDisabled()
					optionIndex = @$options.index $ evt.currentTarget

					@select optionIndex

					if @opts.closeOnSelect then @close()


			_handleWindowClick: (evt) =>
				if not @isDisabled() and @isOpen() and @opts.closeOnClickOutside and not $.contains @$el.get(0), evt.target
					@close()


			onSelectOption: (selectionHandler) ->
				@selectionHandlers.push selectionHandler


			offSelectOption: (selectionHandler) ->
				handlerIndex = @selectionHandlers.indexOf selectionHandler

				if handlerIndex >= 0
					@selectionHandlers.splice handlerIndex, 1


			removeAllHandlers: () ->
				@selectionHandlers = []


			close: () =>
				if @isDisabled() then return undefined
				@$menu.hide()
				@data.isOpen = false


			disable: () ->
				@close()
				@$el.addClass 'b_dropdown-disabled'
				@$hiddenInput.prop 'disabled', true
				@data.isDisabled = true


			enable: () ->
				@$el.removeClass 'b_dropdown-disabled'
				@$hiddenInput.prop 'disabled', false
				@data.isDisabled = false


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
					index = @$options.index $el

				return @getOptionByIndex index


			getOptionByIndex: (optionIndex) ->
				return if @data.ddOptions.length > optionIndex then @data.ddOptions[optionIndex] else null


			getSelectedIndex: () ->
				selectedOption = @getSelectedOption()
				return if selectedOption then selectedOption.getIndex() else -1


			getSelectedLabel: () ->
				selectedOption = @getSelectedOption()
				return if selectedOption then selectedOption.getLabel() else null


			getSelectedOption: () ->
				return @data.selectedOption or null


			getSelectedValue: () ->
				selectedOption = @getSelectedOption()
				return if selectedOption then selectedOption.getValue() else null


			isDisabled: () ->
				return @data.isDisabled


			navigateToLink: (link) ->
				location.href = link


			open: () =>
				if @isDisabled() then return undefined
				@$menu.show()
				@data.isOpen = true


			resetSelection: () =>
				@data.selectedOption = undefined
				@$hiddenInput.val ''

				if not @opts.staticHeader
					@$toggleHeader.empty()
					@$toggleHeader.html @opts.placeholder or ""


			select: (indexOrElement, preventEvent) =>
				option = @getOption indexOrElement

				if option
					timestamp = new Date()

					@data.selectedOption = option

					if not @opts.staticHeader
						@$toggleHeader.empty()
						@$toggleHeader.html option.getLabel()

					@$hiddenInput.val option.getValue()

					if not preventEvent
						for selectionHandler in @selectionHandlers
							do (selectionHandler) =>
								selectionHandler.call @,
									dropdown : @
									option   : option
									timestamp: timestamp

				else
					#Reset dropdown value if no valid index or element is provided
					@resetSelection()


			toggle: () =>
				if @isOpen() then @close() else @open()


			isOpen: () ->
				return @data.isOpen or false


			destroy: () ->
				@enable()
				@unbindEvents()


		# Private dropdown option helper class
		class Option

			constructor: (dropdown, option) ->
				@dropdown = dropdown

				if option instanceof Option
					@$el = option.$el

				else if option instanceof $
					@$el = option.eq 0

				else if option instanceof HTMLElement
					@$el = $ option

				else if typeof option is 'number'
					@index = option
					@$el   = @options.eq option

				else
					throw "Provided argument is neither a html element nor a number"

				@isLink = if @$el.find('a').length then true else false


			get$El: () ->
				return @$el


			getIndex: (refresh) ->
				if refresh or not @index?
					@index = @dropdown.$options.index @$el

				return @index


			getLabel: (refresh) ->
				if refresh or not @label?
					@label = @$el.text()
				return @label


			getValue: (refresh) ->
				if refresh or not @value?

					if @isLink
						value = @$el.attr 'href'
					else
						value = @$el.data 'value'

					if not value?
						value = @getLabel refresh

					@value = value

				return @value


			isLink: () ->
				return @isLink


		#Helper functions
		__setElementAttribute = ($el, attribute) ->
			if attribute.nodeName isnt 'name'
				$el.attr attribute.nodeName, attribute.value


		return Dropdown