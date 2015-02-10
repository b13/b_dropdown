define ['jquery'],
	($) ->

		class BaseDropdown
			constructor: (el, opts) ->
				@opts = opts or {}

				@$el      = $ el
				@$header  = @$el.find 'button.dropdown-toggle'
				@$menu    = @$el.find 'ul.dropdown-menu'
				@$options = @$menu.children('li')

				@selectionHandlers = []

				@data = {}

				if @opts.staticHeaderText
					@data.staticHeaderText = @opts.staticHeaderText
					@$header.html '<span>' + @data.staticHeaderText + '</span>'

				@close();

			bindEvents: () ->


			unbindEvents: () ->


			_handleOptionSelection: (evt) =>
				optionIndex = @$options.index $ evt.currentTarget

				@setActiveOption optionIndex
				@close()


			_handleWindowClick: (evt) =>
				if @isOpen() and not $.contains @$el.get(0), evt.target
						@close()


			onSelectOption: (selectionHandler) ->
				@selectionHandlers.push selectionHandler


			offSelectOption: (selectionHandler) ->
				handlerIndex = @selectionHandlers.indexOf selectionHandler

				if handlerIndex >= 0
					@selectionHandlers.splice handlerIndex, 1


			removeAllHandlers: () ->
				@selectionHandlers = []

			close: () ->
				@$menu.removeClass 'show'
				@$menu.addClass 'hidden'
				@data.isOpen = false


			open: () ->
				@$menu.removeClass 'hidden'
				@$menu.addClass 'show'
				@data.isOpen = true

			navigateToLink: (link) ->
				location.href = link


			getActiveOption: () ->
				return @data.selectedOption ? if @options.length then {$el: @options.eq(0), index: 0} else undefined


			setActiveOption: (index, preventEvent) ->

				if @$options.length > index
					$option = @options.eq index
					timestamp = new Date()

					@data.selectedOption =
						$el  : $option
						index: index

					if not @data.staticHeaderText
						@$header.empty()
						@$header.html $option.html()

					if not preventEvent
						for selctionHandler in @selectionHandlers
							do (selectionHandler) ->
								selectionHandler.call @,
									$option    : $option
									optionIndex: index
									timestamp  : timestamp


			toggle: () ->
				if @isOpen() then @close() else @open()


			isOpen: () ->
				return @data.isOpen  or false


			destroy: () ->
				@unbindEvents()


		return BaseDropdown