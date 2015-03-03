define 'b_dropdown',
	['jquery'],
	($) ->

		class Dropdown

			defaultOpts:
				closeOnSelect: true

			constructor: (el, opts) ->

				@opts = $.extend {}, @defaultOpts, opts or {}

				@$el           = $ el
				@$toggleHeader = @$el.find '.b_dropdown-toggle'
				@$menu         = @$el.find 'ul'
				@$options      = @$menu.children 'li'
				@$hiddenInput  = @$el.find 'input[type=hidden]'

				@selectionHandlers = []

				@data =
					isOpen    : false
					isDisabled: false
					ddOptions   : @_initDropdownOptions()

				if @opts.staticHeaderText
					@$toggleHeader.html '<span>' + @opts.staticHeaderText + '</span>'
				else
					if @opts.placeholderHeaderText
						@$toggleHeader.html '<span>' + @opts.placeholderHeaderText + '</span>'

				@close()

				@bindEvents()

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

					@selectOption optionIndex
					if @opts.closeOnSelect then @close()


			_handleWindowClick: (evt) =>
				if not @isDisabled() and @isOpen() and not $.contains @$el.get(0), evt.target
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


			selectOption: (indexOrElement, preventEvent) =>
				option = @getOption indexOrElement

				if option
					timestamp = new Date()

					@data.selectedOption = option

					if not @opts.staticHeaderText
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


		return Dropdown