define 'b_dropdown-base',
	[
		'jquery'
		'b_dropdown-option'
	],
	($, Option) ->

		class BaseDropdown

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
					options   : @_initOptions()

				if @opts.staticHeaderText
					@$toggleHeader.html '<span>' + @opts.staticHeaderText + '</span>'
				else
					if @opts.placeholderHeaderText
						@$toggleHeader.html '<span>' + @opts.placeholderHeaderText + '</span>'

				@close()

				@bindEvents()

			_initOptions: () ->
				dropddown = @
				options = []

				@$options.each ()->
					options.push new Option dropddown, @

				return options;


			bindEvents: () ->
				@$toggleHeader.on 'click', @toggle
				@$options.on 'click', @_handleOptionSelection
				$(window).on 'click', @_handleWindowClick


			unbindEvents: () ->
				@$toggleHeader.off 'click', @toggle
				$(window).off 'click', @_handleWindowClick


			_handleOptionSelection: (evt) =>
				if @isDisabled() then return undefined;
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
					index = @data.options.indexOf indexOrElement

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
				return if @data.options.length > optionIndex then @data.options[optionIndex] else null


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
				@$menu.show()
				@data.isOpen = true


			selectOption: (indexOrElement, preventEvent) =>
				dropdown = @
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
				@unbindEvents()


		return BaseDropdown




