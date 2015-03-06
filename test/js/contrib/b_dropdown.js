(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define('b_dropdown', ['jquery'], function($) {
    var Dropdown, Option;
    Dropdown = (function() {
      Dropdown.prototype.defaultOpts = {
        hideOriginalSelect: true
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
        this.$mockEl = $('<div class="b_dropdown"></div>');
        this.$selectEl.after(this.$mockEl);
        this.$selectEl.addClass('b_dropdown-select');
        this._renderMockHTMLFromData(this.$mockEl, renderData);
        this.$mockToggleHeader = this.$mockEl.find('.b_dropdown-toggle');
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
        if (this.$selectEl.prop('disabled')) {
          this.disable();
        }
        this._bindEvents();
      }

      Dropdown.prototype._renderMockHTMLFromData = function($targetEl, renderData) {
        var $mockMenu, $mockMenuWrap, $newOptionEl, label, option, value, _i, _len, _ref, _results;
        $targetEl.append($('<button class="b_dropdown-toggle"></button>'));
        $mockMenuWrap = $('<div class="b_dropdown-menuWrap"></div>');
        $targetEl.append($mockMenuWrap);
        $mockMenu = $('<ul></ul>');
        $mockMenuWrap.append($mockMenu);
        _ref = renderData.options;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          option = _ref[_i];
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
            _results.push($newOptionEl.addClass('b_dropdown-disabled'));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };

      Dropdown.prototype._getRenderDataFromSelectStructure = function($selectElement) {
        var $optionsEls, renderData;
        renderData = {
          options: []
        };
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

      Dropdown.prototype._initDropdownOptions = function() {
        var ddOptions, dropddown;
        dropddown = this;
        ddOptions = [];
        this.$realOptions.each(function() {
          return ddOptions.push(new Option(dropddown, this));
        });
        return ddOptions;
      };

      Dropdown.prototype._bindEvents = function() {
        this.$mockToggleHeader.on('click', this._handleToggleBtnClick);
        this.$mockOptions.on('click', this._handleMockOptionSelection);
        this.$selectEl.on('change', this._handleChange);
        return $(window).on('click', this._handleWindowClick);
      };

      Dropdown.prototype._handleMockOptionSelection = function(evt) {
        this.select(this.$mockOptions.index($(evt.currentTarget)));
        return this.closeMock();
      };

      Dropdown.prototype._handleChange = function(evt) {
        var option;
        option = this._updateSelect(this.$realOptions.filter(':selected'), false, true, false, true);
        if (option && !option.isDisabled()) {
          return this.closeMock();
        }
      };

      Dropdown.prototype._handleToggleBtnClick = function(evt) {
        evt.preventDefault();
        return this.toggleMock();
      };

      Dropdown.prototype._handleWindowClick = function(evt) {
        if (!this.isDisabled() && this.isMockOpen() && !$.contains(this.$mockEl.get(0), evt.target)) {
          return this.closeMock();
        }
      };

      Dropdown.prototype._unbindEvents = function() {
        this.$mockToggleHeader.off('click', this._handleToggleBtnClick);
        this.$mockOptions.off('click', this._handleMockOptionSelection);
        this.$selectEl.off('change', this._handleChange);
        return $(window).off('click', this._handleWindowClick);
      };

      Dropdown.prototype._updateSelect = function(indexOrElement, updateSelect, updateMock, triggerChange, callChangeHandlers) {
        var changeHandler, option, timestamp, _i, _len, _ref;
        option = this.getOption(indexOrElement);
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
          if (callChangeHandlers) {
            _ref = this.changeHandlers;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              changeHandler = _ref[_i];
              changeHandler.call(this, {
                dropdown: this,
                option: option,
                timestamp: timestamp
              });
            }
          }
        }
        return option;
      };

      Dropdown.prototype.closeMock = function() {
        if (!this.isDisabled()) {
          this.$mockMenu.hide();
          this.data.isMockOpen = false;
        }
        return this;
      };

      Dropdown.prototype.destroy = function() {
        this.$selectEl.removeClass('b_dropdown-select');
        this.$mockEl.remove();
        this._unbindEvents();
        delete this;
        return void 0;
      };

      Dropdown.prototype.disable = function() {
        this.closeMock();
        this.$selectEl.prop('disabled', true);
        this.$mockEl.addClass('b_dropdown-disabled');
        this.data.isDisabled = true;
        return this;
      };

      Dropdown.prototype.disableOption = function(indexOrElement) {
        var option;
        option = this.getOption(indexOrElement);
        if (option) {
          option.disable();
        }
        return option;
      };

      Dropdown.prototype.enable = function() {
        this.$selectEl.prop('disabled', false);
        this.$mockEl.removeClass('b_dropdown-disabled');
        this.data.isDisabled = false;
        return this;
      };

      Dropdown.prototype.enableOption = function(indexOrElement) {
        var option;
        option = this.getOption(indexOrElement);
        if (option) {
          option.enable();
        }
        return option;
      };

      Dropdown.prototype.getOption = function(indexOrElement) {
        var $el, index;
        if (indexOrElement instanceof Option) {
          index = this.data.ddOptions.indexOf(indexOrElement);
        } else if (indexOrElement instanceof $) {
          $el = indexOrElement;
        } else if (indexOrElement instanceof HTMLElement) {
          $el = $(indexOrElement);
        } else if (typeof indexOrElement === 'number') {
          index = indexOrElement;
        } else {
          throw "Provided argument is neither a html element nor a number";
        }
        if ($el) {
          index = this.$realOptions.index($el);
        }
        return this.getOptionByIndex(index);
      };

      Dropdown.prototype.getOptionByIndex = function(optionIndex) {
        if (this.data.ddOptions.length > optionIndex) {
          return this.data.ddOptions[optionIndex];
        } else {
          return void 0;
        }
      };

      Dropdown.prototype.getSelectedIndex = function() {
        var selectedOption;
        selectedOption = this.getSelectedOption();
        if (selectedOption) {
          return selectedOption.getIndex();
        } else {
          return -1;
        }
      };

      Dropdown.prototype.getSelectedLabel = function() {
        var selectedOption;
        selectedOption = this.getSelectedOption();
        if (selectedOption) {
          return selectedOption.getLabel();
        } else {
          return void 0;
        }
      };

      Dropdown.prototype.getSelectedOption = function() {
        return this.data.selectedOption || void 0;
      };

      Dropdown.prototype.getSelectedValue = function() {
        var selectedOption;
        selectedOption = this.getSelectedOption();
        if (selectedOption) {
          return selectedOption.getValue();
        } else {
          return void 0;
        }
      };

      Dropdown.prototype.isDisabled = function() {
        return this.data.isDisabled;
      };

      Dropdown.prototype.isMockOpen = function() {
        return this.data.isMockOpen || false;
      };

      Dropdown.prototype.offChange = function(changeHandler) {
        var handlerIndex;
        handlerIndex = this.changeHandlers.indexOf(changeHandler);
        if (handlerIndex >= 0) {
          this.changeHandlers.splice(handlerIndex, 1);
          return changeHandler;
        }
        return void 0;
      };

      Dropdown.prototype.onChange = function(changeHandler) {
        this.changeHandlers.push(changeHandler);
        return changeHandler;
      };

      Dropdown.prototype.openMock = function() {
        if (!this.isDisabled()) {
          this.$mockMenu.show();
          this.data.isMockOpen = true;
        }
        return this;
      };

      Dropdown.prototype.removeAllHandlers = function() {
        var removedHandlers;
        removedHandlers = this.changeHandlers;
        this.changeHandlers = [];
        return removedHandlers;
      };

      Dropdown.prototype.resetSelection = function() {
        this.select(0, true);
        if (!this.opts.staticHeader) {
          this.$mockToggleHeader.empty();
          this.$mockToggleHeader.html(this.opts.placeholder || "");
        }
        return this;
      };

      Dropdown.prototype.select = function(indexOrElement) {
        return this._updateSelect(indexOrElement, true, true, true, true);
      };

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

      Option.prototype.disable = function() {
        this.disabled = true;
        this.$realEl.prop('disabled', true);
        return this.$mockEl.addClass('b_dropdown-disabled');
      };

      Option.prototype.enable = function() {
        this.disabled = false;
        this.$realEl.prop('disabled', false);
        return this.$mockEl.removeClass('b_dropdown-disabled');
      };

      Option.prototype.get$RealEl = function() {
        return this.$realEl;
      };

      Option.prototype.get$MockEl = function() {
        return this.$mockEl;
      };

      Option.prototype.getIndex = function() {
        if (this.index == null) {
          this.index = this.dropdown.$realOptions.index(this.$realEl);
        }
        return this.index;
      };

      Option.prototype.getLabel = function(refresh) {
        if (refresh || (this.label == null)) {
          this.label = this.$realEl.text();
        }
        return this.label;
      };

      Option.prototype.getValue = function(refresh) {
        if (refresh || (this.value == null)) {
          this.value = this.$realEl.val() || "";
        }
        return this.value;
      };

      Option.prototype.isDisabled = function(refresh) {
        if (refresh || (this.disabled == null)) {
          this.disabled = this.$realEl.prop('disabled');
        }
        return this.disabled;
      };

      return Option;

    })();
    return Dropdown;
  });

}).call(this);
