(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define('b_dropdown', ['jquery'], function($) {
    var Dropdown, Option;
    Dropdown = (function() {
      Dropdown.prototype.defaultOpts = {
        disabled: void 0,
        firstOptionIsPlaceholder: false,
        hideOriginalSelect: true
      };


      /*
        		@param $parentEl
         @param JSONData
         @param opts
         @return {Dropdown}
      
        		Renders a HTML select structure based on given JSON data, inserts it into the given $parentEl and creates a new
        		Dropdown based on the rendered select structure.
       */

      Dropdown.createDropdownFromJSON = function($parentEl, JSONData, opts) {
        var $selectEl;
        $selectEl = this._renderSelectFromJSON($parentEl, JSONData);
        return new Dropdown($selectEl, opts);
      };


      /*
        		@param $parentEl
         @param JSONData
        		@return {jQuery}
      
        		Renders a HTML select structure based on given JSON data, inserts it into the given $parentEl.
       */

      Dropdown._renderSelectFromJSON = function($parentEl, JSONData) {
        var $newOption, $selectEl, option, _i, _len, _ref;
        $selectEl = $('<select></select>');
        $parentEl.append($selectEl);
        if (JSONData.name) {
          $selectEl.attr('name', JSONData.name);
        }
        _ref = JSONData.options;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          option = _ref[_i];
          $newOption = $('<option></option>');
          $selectEl.append($newOption);
          if (option.value) {
            $newOption.val(option.value);
          }
          if (option.disabled) {
            $newOption.prop('disabled', true);
          }
          if (option.label) {
            $newOption.text(option.label);
          }
        }
        return $selectEl;
      };

      function Dropdown(el, opts) {
        this.toggleMock = __bind(this.toggleMock, this);
        this.select = __bind(this.select, this);
        this.resetSelection = __bind(this.resetSelection, this);
        this.openMock = __bind(this.openMock, this);
        this.closeMock = __bind(this.closeMock, this);
        this._handleWindowClick = __bind(this._handleWindowClick, this);
        this._handleToggleBtnClick = __bind(this._handleToggleBtnClick, this);
        this._handleChange = __bind(this._handleChange, this);
        this._handleMockOptionSelection = __bind(this._handleMockOptionSelection, this);
        var renderData;
        this.$selectEl = $(el);
        this.$realOptions = this.$selectEl.children('option');
        this.opts = $.extend({}, this.defaultOpts, opts || {});
        if (this.$selectEl.prop('tagName') !== 'SELECT') {
          throw "The provided HTML element is no <select> element";
        }
        renderData = this._getRenderDataFromSelectStructure(this.$selectEl);
        if (!this.opts.selectedOption && (renderData.selectedOption != null)) {
          this.opts.selectedOption = renderData.selectedOption;
        }
        this.$mockEl = $('<div class="bJS_md_dropdown b_md_dropdown"></div>');
        this.$selectEl.before(this.$mockEl);
        this.$selectEl.addClass('b_md_dropdown-select');
        this._renderMockHTMLFromData(this.$mockEl, renderData);
        this.$mockToggleHeader = this.$mockEl.find('.bJS_md_dropdown-toggle');
        this.$mockMenu = this.$mockEl.find('ul');
        this.$mockOptions = this.$mockMenu.children('li');
        this.data = {
          isMockOpen: false,
          isDisabled: false,
          ddOptions: this._initDropdownOptions()
        };
        this.changeHandlers = [];
        if (this.opts.staticHeader) {
          this.$mockToggleHeader.html('<span>' + this.opts.staticHeader + '</span>');
        }
        if ((this.opts.selectedOption != null) && this.opts.selectedOption >= 0) {
          this.select(this.opts.selectedOption, true);
        } else {
          this.select(0, true);
        }
        if (this.opts.disabled === false) {
          this.enable();
        } else if (this.opts.disabled || this.$selectEl.prop('disabled')) {
          this.disable();
        }
        this._bindEvents();
      }


      /*
        		@param $targetEl
         @param renderData
         @return {jQuery}
         @private
      
      			Renders the mock structure based on information that was extracted from the select structure
       */

      Dropdown.prototype._renderMockHTMLFromData = function($targetEl, renderData) {
        var $mockMenu, $mockMenuWrap, $newOptionEl, i, label, option, value, _i, _len, _ref;
        if (renderData.selectId) {
          $targetEl.data('for', renderData.selectId);
        }
        $targetEl.append($('<button class="bJS_md_dropdown-toggle b_md_dropdown-toggle"></button>'));
        $mockMenuWrap = $('<div class="b_md_dropdown-menuWrap"></div>');
        $targetEl.append($mockMenuWrap);
        $mockMenu = $('<ul></ul>');
        $mockMenuWrap.append($mockMenu);
        _ref = renderData.options;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          option = _ref[i];
          if (typeof option === 'string') {
            label = option;
            value = option;
          } else {
            value = option.value;
            label = option.label || value;
          }
          $newOptionEl = $('<li data-value="' + value + '"></li>');
          $mockMenu.append($newOptionEl);
          $newOptionEl.text(label);
          if (option.disabled) {
            $newOptionEl.addClass('b_md_dropdown-disabled');
          }
          if (i === 0 && this.opts.firstOptionIsPlaceholder) {
            $newOptionEl.addClass('b_md_dropdown-placeholder');
          }
        }
        return $targetEl;
      };


      /*
      			@param $selectElement
      			@return {{options: Array}}
      			@private
      
        		Gets information from the select about how the mock structure must be rendered.
       */

      Dropdown.prototype._getRenderDataFromSelectStructure = function($selectElement) {
        var $optionsEls, renderData, selectId;
        renderData = {
          options: []
        };
        selectId = $selectElement.attr('id');
        if (selectId) {
          renderData.selectId = renderData;
        }
        $optionsEls = $selectElement.children('option');
        $optionsEls.each(function(index) {
          var $option, nextOptionObject;
          nextOptionObject = {};
          $option = $(this);
          nextOptionObject.label = $option.text() || "";
          nextOptionObject.value = $option.val() || nextOptionObject.label;
          nextOptionObject.disabled = $option.prop('disabled');
          nextOptionObject.selected = $option.prop('selected');
          if (nextOptionObject.selected) {
            renderData.selectedOption = index;
          }
          return renderData.options.push(nextOptionObject);
        });
        return renderData;
      };


      /*
      			return {Array}
        		@private
      
        		Initializes the option objects that will be used to manage the dropdowns state.
       */

      Dropdown.prototype._initDropdownOptions = function() {
        var ddOptions, dropddown;
        dropddown = this;
        ddOptions = [];
        this.$realOptions.each(function() {
          return ddOptions.push(new Option(dropddown, this));
        });
        return ddOptions;
      };


      /*
        		return {Dropdown}
        		@private
      
        		Binds the needed event handlers to DOM events.
       */

      Dropdown.prototype._bindEvents = function() {
        this.$mockToggleHeader.on('click', this._handleToggleBtnClick);
        this.$mockOptions.on('click', this._handleMockOptionSelection);
        this.$selectEl.on('change', this._handleChange);
        $(window).on('click', this._handleWindowClick);
        return this;
      };


      /*
        		@param evt
        		@return {void 0}
        		@private
      
        		Handler for the click event on mock option HTML elements.
        		Calls an update on the dropdown.
       */

      Dropdown.prototype._handleMockOptionSelection = function(evt) {
        this.select(this.$mockOptions.index($(evt.currentTarget)));
        this.closeMock();
        return void 0;
      };


      /*
        		@return {void 0}
        		@private
      
        		Handler for the select element change event.
        		Calls an update on the dropdown.
       */

      Dropdown.prototype._handleChange = function() {
        var option;
        option = this._updateSelect(this.$realOptions.filter(':selected'), false, true, false, true);
        if (option && !option.isDisabled()) {
          this.closeMock();
        }
        return void 0;
      };


      /*
        		@param evt
        		@return {void 0}
        		@private
      
        		Handler for the click event on the header button of the mock structure.
        		Toggles the mocks open state.
       */

      Dropdown.prototype._handleToggleBtnClick = function(evt) {
        evt.preventDefault();
        this.toggleMock();
        return void 0;
      };


      /*
        		@param evt
        		@private
      
        		Handler that will be bound to the windows click event.
        		Calls close if the click was outside the select and outside the mock.
       */

      Dropdown.prototype._handleWindowClick = function(evt) {
        if (!this.isDisabled() && this.isMockOpen() && !$.contains(this.$mockEl.get(0), evt.target)) {
          this.closeMock();
        }
        return void 0;
      };


      /*
        		@return {Dropdown}
        		@private
      
        		Unbinds all handlers that was bound on _bindEvents() from their events.
       */

      Dropdown.prototype._unbindEvents = function() {
        this.$mockToggleHeader.off('click', this._handleToggleBtnClick);
        this.$mockOptions.off('click', this._handleMockOptionSelection);
        this.$selectEl.off('change', this._handleChange);
        $(window).off('click', this._handleWindowClick);
        this.removeChangeHandlers();
        return this;
      };


      /*
        		@param indexElementOrOption
        		@param updateSelect
        		@param updateMock
        		@param triggerChange
        		@param callChangeHandlers
        		@return {Option}
        		@private
      
        		Private helper function that is essentially for the state and view update of the dropdown.
       */

      Dropdown.prototype._updateSelect = function(indexElementOrOption, updateSelect, updateMock, triggerChange) {
        var option, timestamp;
        option = this.getOption(indexElementOrOption);
        timestamp = new Date();
        if (option && !option.isDisabled()) {
          this.data.selectedOption = option;
          if (updateSelect) {
            option.$realEl.prop('selected', true);
          }
          if (updateMock) {
            this.$mockToggleHeader.text(option.getLabel());
          }
          if (triggerChange) {
            this.$selectEl.trigger('change');
          }
        }
        return option;
      };


      /*
      			@return {Dropdown}
      
        		Closes the mock menu.
       */

      Dropdown.prototype.closeMock = function() {
        if (!this.isDisabled()) {
          this.$mockEl.removeClass('b_md_dropdown-open');
          this.data.isMockOpen = false;
        }
        return this;
      };


      /*
        		@return {void 0}
      
        		Destroys the dropdown. That means:
        		- Removing b_dropdown specific css classes.
        		- Destroying the mock structure.
        		- Unbinding all b_dropdown event handlers.
       */

      Dropdown.prototype.destroy = function() {
        this.$selectEl.removeClass('b_md_dropdown-select');
        this.$mockEl.remove();
        this._unbindEvents();
        delete this;
        return void 0;
      };


      /*
        		@return {Dropdown}
      
        		Sets the select as disabled and emulates a similar behaviour for the mock.
       */

      Dropdown.prototype.disable = function() {
        this.closeMock();
        this.$selectEl.prop('disabled', true);
        this.$mockEl.addClass('b_md_dropdown-disabled');
        this.data.isDisabled = true;
        return this;
      };


      /*
        		@param indexElementOrOption
        		@return {Option}
      
        		Disables an option and its mock pendant.
       */

      Dropdown.prototype.disableOption = function(indexElementOrOption) {
        var option;
        option = this.getOption(indexElementOrOption);
        if (option) {
          option.disable();
        }
        return option;
      };


      /*
        		@return {Dropdown}
      
        		Enables the select and its mock pendant.
       */

      Dropdown.prototype.enable = function() {
        this.$selectEl.prop('disabled', false);
        this.$mockEl.removeClass('b_md_dropdown-disabled');
        this.data.isDisabled = false;
        return this;
      };


      /*
        		@param indexElementOrOption
        		@return {Option}
      
        		Enables an option and its mock pendant.
       */

      Dropdown.prototype.enableOption = function(indexElementOrOption) {
        var option;
        option = this.getOption(indexElementOrOption);
        if (option) {
          option.enable();
        }
        return option;
      };


      /*
        		@return {string}
      
        		Returns the label of an option either based on its corresponding index, its HTML element or a jQuery collection that wraps
        		the corresponding HTML element.
       */

      Dropdown.prototype.getLabelForOption = function(indexElementOrOption) {
        var option;
        option = this.getOption(indexElementOrOption);
        if (option) {
          return option.getLabel();
        }
        return void 0;
      };


      /*
        		@param indexElementOrOption
        		@return {Option}
      
        		Returns an option either based on its corresponding index, its HTML element or a jQuery collection that wraps
        		the corresponding HTML element.
       */

      Dropdown.prototype.getOption = function(indexElementOrOption) {
        var $el, index;
        if (indexElementOrOption instanceof Option) {
          index = this.data.ddOptions.indexOf(indexElementOrOption);
        } else if (indexElementOrOption instanceof $) {
          $el = indexElementOrOption;
        } else if (indexElementOrOption instanceof HTMLElement) {
          $el = $(indexElementOrOption);
        } else if (typeof indexElementOrOption === 'number') {
          index = indexElementOrOption;
        } else {
          throw "Provided argument is neither a html element nor a number";
        }
        if ($el) {
          index = this.$realOptions.index($el);
        }
        return this.getOptionByIndex(index);
      };


      /*
        		@param optionIndex
        		@return {Option}
      
        		Returns an option based on its order in the select structure.
       */

      Dropdown.prototype.getOptionByIndex = function(optionIndex) {
        if (this.data.ddOptions.length > optionIndex) {
          return this.data.ddOptions[optionIndex];
        } else {
          return void 0;
        }
      };


      /*
        		@return {number}
      
        		Returns the index of the selected option.
       */

      Dropdown.prototype.getSelectedIndex = function() {
        var selectedOption;
        selectedOption = this.getSelectedOption();
        if (selectedOption) {
          return selectedOption.getIndex();
        } else {
          return 0;
        }
      };


      /*
        		@return {string}
      
        		Returns the text that is displayed in the option or an empty string.
       */

      Dropdown.prototype.getSelectedLabel = function() {
        var selectedOption;
        selectedOption = this.getSelectedOption();
        if (selectedOption) {
          return selectedOption.getLabel();
        } else {
          return "";
        }
      };


      /*
        		@return {Option}
      
        		Returns the Option object of the selected option.
       */

      Dropdown.prototype.getSelectedOption = function() {
        return this.data.selectedOption || this.getOptionByIndex(0);
      };


      /*
        		@return {*}
      
        		Returns the value of the selected option.
       */

      Dropdown.prototype.getSelectedValue = function() {
        var selectedOption;
        selectedOption = this.getSelectedOption();
        if (selectedOption) {
          return selectedOption.getValue();
        } else {
          return void 0;
        }
      };


      /*
      			@return {string}
      
      			Returns the value of an option either based on its corresponding index, its HTML element or a jQuery collection that wraps
      			the corresponding HTML element.
       */

      Dropdown.prototype.getValueOfOption = function(indexElementOrOption) {
        var option;
        option = this.getOption(indexElementOrOption);
        if (option) {
          return option.getValue();
        }
        return void 0;
      };


      /*
        		@return {boolean}
      
        		Returns true if the select is disabled.
       */

      Dropdown.prototype.isDisabled = function() {
        return this.data.isDisabled;
      };


      /*
        		@return {boolean}
      
        		Returns true if the mock menu is open.
       */

      Dropdown.prototype.isMockOpen = function() {
        return this.data.isMockOpen || false;
      };


      /*
        		@param changeHandler
      
        		Unbinds handlers from the change event.
       */

      Dropdown.prototype.offChange = function(changeHandler) {
        var handlerIndex;
        handlerIndex = this.changeHandlers.indexOf(changeHandler);
        this.$selectEl.off('change', changeHandler);
        if (handlerIndex >= 0) {
          this.changeHandlers.splice(handlerIndex, 1);
          return changeHandler;
        }
        return void 0;
      };


      /*
      			@param changeHandler
      
      			Binds handlers to the change event.
       */

      Dropdown.prototype.onChange = function(changeHandler) {
        this.changeHandlers.push(changeHandler);
        this.$selectEl.on('change', changeHandler);
        return changeHandler;
      };


      /*
        		@return {Dropdown}
      
        		Opens the mock menu.
       */

      Dropdown.prototype.openMock = function() {
        if (!this.isDisabled()) {
          this.$mockEl.addClass('b_md_dropdown-open');
          this.data.isMockOpen = true;
        }
        return this;
      };


      /*
        		@return {Array}
      
        		Removes all handlers that where bound via the onChange function.
       */

      Dropdown.prototype.removeChangeHandlers = function() {
        var changeHandler, removedHandlers, _i, _len, _ref;
        _ref = this.changeHandlers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          changeHandler = _ref[_i];
          this.offChange(changeHandler);
        }
        removedHandlers = this.changeHandlers;
        this.changeHandlers = [];
        return removedHandlers;
      };


      /*
        		@return {Option}
      
        		Selects the first option, no matter if it is used as placeholder or not.
       */

      Dropdown.prototype.resetSelection = function() {
        return this.select(0);
      };


      /*
        		@return {Option}
      
        		Selects an option either based on its corresponding index, its HTML element or a jQuery collection that wraps
        		the corresponding HTML element.
       */

      Dropdown.prototype.select = function(indexElementOrOption) {
        return this._updateSelect(indexElementOrOption, true, true, true, true);
      };


      /*
        		@return {string}
      
        		Sets the label for an option either based on its corresponding index, its HTML element or a jQuery collection that wraps
        		the corresponding HTML element.
       */

      Dropdown.prototype.setLabelForOption = function(indexElementOrOption, label) {
        var option;
        option = this.getOption(indexElementOrOption);
        if (option) {
          return option.setLabel(label);
        }
        return void 0;
      };


      /*
      			@return {string}
      
      			Sets the value for an option either based on its corresponding index, its HTML element or a jQuery collection that wraps
      			the corresponding HTML element.
       */

      Dropdown.prototype.setValueForOption = function(indexElementOrOption, value) {
        var option;
        option = this.getOption(indexElementOrOption);
        if (option) {
          return option.setValue(value);
        }
        return void 0;
      };


      /*
        		@return {Dropdown}
      
        		Toggles the open state of the mock menu.
       */

      Dropdown.prototype.toggleMock = function() {
        if (this.isMockOpen()) {
          this.closeMock();
        } else {
          this.openMock();
        }
        return this;
      };

      return Dropdown;

    })();
    Option = (function() {
      function Option(dropdown, option) {
        this.dropdown = dropdown;
        if (option instanceof Option) {
          this.$realEl = option.$realEl;
        } else if (option instanceof $) {
          this.$realEl = option.eq(0);
        } else if (option instanceof HTMLElement) {
          this.$realEl = $(option);
        } else if (typeof option === 'number') {
          this.index = option;
          this.$realEl = this.dropdown.$realOptions.eq(option);
        } else {
          throw "Provided argument is neither a html element nor a number";
        }
        if (this.index == null) {
          this.index = this.dropdown.$realOptions.index(this.$realEl);
        }
        this.$mockEl = this.dropdown.$mockOptions.eq(this.index);
        this.isDisabled();
        this.getLabel();
        this.getValue();
      }


      /*
        		@return {Option}
      
        		Disables the option and its views.
       */

      Option.prototype.disable = function() {
        this.disabled = true;
        this.$realEl.prop('disabled', true);
        this.$mockEl.addClass('b_md_dropdown-disabled');
        return this;
      };


      /*
        		@return {Option}
      
        		Enables the option and its views.
       */

      Option.prototype.enable = function() {
        this.disabled = false;
        this.$realEl.prop('disabled', false);
        this.$mockEl.removeClass('b_md_dropdown-disabled');
        return this;
      };


      /*
        		@return {jQuery}
      
        		Returns the corresponding <option> HTML element of the option, wrapped in a jQuery collection.
       */

      Option.prototype.get$RealEl = function() {
        return this.$realEl;
      };


      /*
      			@return {jQuery}
      
      			Returns the corresponding mock HTML element of the option, wrapped in a jQuery collection.
       */

      Option.prototype.get$MockEl = function() {
        return this.$mockEl;
      };


      /*
        		@return {number}
      
        		Returns the index of the option.
       */

      Option.prototype.getIndex = function(refresh) {
        if (refresh || (this.index == null)) {
          this.index = this.dropdown.$realOptions.index(this.$realEl);
        }
        return this.index;
      };


      /*
        		@return {string}
      
        		Returns the text that is visible in the option, if available.
       */

      Option.prototype.getLabel = function(refresh) {
        if (refresh || (this.label == null)) {
          this.label = this.$realEl.text();
        }
        return this.label;
      };


      /*
        		@return {string}
      
        		Returns the value of the option, if available.
       */

      Option.prototype.getValue = function(refresh) {
        if (refresh || (this.value == null)) {
          this.value = this.$realEl.val() || "";
        }
        return this.value;
      };


      /*
        		@return {string}
      
        		Sets the text that will be displayed as option.
       */

      Option.prototype.setLabel = function(label) {
        this.label = label;
        this.$realEl.text(label);
        this.$mockEl.text(label);
        if (this.isSelected()) {
          this.dropdown.$mockToggleHeader.text(label);
        }
        return label;
      };


      /*
        		@return {string}
      
        		Sets the value of the option.
       */

      Option.prototype.setValue = function(value) {
        this.value = value;
        this.$realEl.val(value);
        return value;
      };


      /*
        		@return {boolean}
      
        		Returns true if the option is disabled. Otherwise false.
       */

      Option.prototype.isDisabled = function(refresh) {
        if (refresh || (this.disabled == null)) {
          this.disabled = this.$realEl.prop('disabled');
        }
        return this.disabled;
      };


      /*
        		@return {boolean}
      
        		Return true if the option is selected. Otherwise false.
       */

      Option.prototype.isSelected = function() {
        return this.$realEl.prop('selected');
      };

      return Option;

    })();
    return Dropdown;
  });

}).call(this);
