define 'b_dropdown-option',
	['jquery'],
	($) ->

		# Dropdown option helper class
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

		return Option