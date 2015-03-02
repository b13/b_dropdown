(function() {
  define('b_dropdown-option', ['jquery'], function($) {
    var Option;
    Option = (function() {
      function Option(dropdown, option) {
        this.dropdown = dropdown;
        if (option instanceof Option) {
          this.$el = option.$el;
        } else if (option instanceof $) {
          this.$el = option.eq(0);
        } else if (option instanceof HTMLElement) {
          this.$el = $(option);
        } else if (typeof option === 'number') {
          this.index = option;
          this.$el = this.options.eq(option);
        } else {
          throw "Provided argument is neither a html element nor a number";
        }
        this.isLink = this.$el.find('a').length ? true : false;
      }

      Option.prototype.get$El = function() {
        return this.$el;
      };

      Option.prototype.getIndex = function(refresh) {
        if (refresh || (this.index == null)) {
          this.index = this.dropdown.$options.index(this.$el);
        }
        return this.index;
      };

      Option.prototype.getLabel = function(refresh) {
        if (refresh || (this.label == null)) {
          this.label = this.$el.text();
        }
        return this.label;
      };

      Option.prototype.getValue = function(refresh) {
        var value;
        if (refresh || (this.value == null)) {
          if (this.isLink) {
            value = this.$el.attr('href');
          } else {
            value = this.$el.data('value');
          }
          if (value == null) {
            value = this.getLabel(refresh);
          }
          this.value = value;
        }
        return this.value;
      };

      Option.prototype.isLink = function() {
        return this.isLink;
      };

      return Option;

    })();
    return Option;
  });

}).call(this);

(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define('b_dropdown-base', ['jquery', 'b_dropdown-option'], function($, Option) {
    var BaseDropdown;
    BaseDropdown = (function() {
      BaseDropdown.prototype.defaultOpts = {
        closeOnSelect: true
      };

      function BaseDropdown(el, opts) {
        this.toggle = __bind(this.toggle, this);
        this.selectOption = __bind(this.selectOption, this);
        this.open = __bind(this.open, this);
        this.close = __bind(this.close, this);
        this._handleWindowClick = __bind(this._handleWindowClick, this);
        this._handleOptionSelection = __bind(this._handleOptionSelection, this);
        this.opts = $.extend({}, this.defaultOpts, opts || {});
        this.$el = $(el);
        this.$toggleHeader = this.$el.find('.b_dropdown-toggle');
        this.$menu = this.$el.find('ul');
        this.$options = this.$menu.children('li');
        this.$hiddenInput = this.$el.find('input[type=hidden]');
        this.selectionHandlers = [];
        this.data = {
          isOpen: false,
          isDisabled: false,
          options: this._initOptions()
        };
        if (this.opts.staticHeaderText) {
          this.$toggleHeader.html('<span>' + this.opts.staticHeaderText + '</span>');
        } else {
          if (this.opts.placeholderHeaderText) {
            this.$toggleHeader.html('<span>' + this.opts.placeholderHeaderText + '</span>');
          }
        }
        this.close();
        this.bindEvents();
      }

      BaseDropdown.prototype._initOptions = function() {
        var dropddown, options;
        dropddown = this;
        options = [];
        this.$options.each(function() {
          return options.push(new Option(dropddown, this));
        });
        return options;
      };

      BaseDropdown.prototype.bindEvents = function() {
        this.$toggleHeader.on('click', this.toggle);
        this.$options.on('click', this._handleOptionSelection);
        return $(window).on('click', this._handleWindowClick);
      };

      BaseDropdown.prototype.unbindEvents = function() {
        this.$toggleHeader.off('click', this.toggle);
        return $(window).off('click', this._handleWindowClick);
      };

      BaseDropdown.prototype._handleOptionSelection = function(evt) {
        var optionIndex;
        if (!this.isDisabled()) {
          optionIndex = this.$options.index($(evt.currentTarget));
          this.selectOption(optionIndex);
          if (this.opts.closeOnSelect) {
            return this.close();
          }
        }
      };

      BaseDropdown.prototype._handleWindowClick = function(evt) {
        if (!this.isDisabled() && this.isOpen() && !$.contains(this.$el.get(0), evt.target)) {
          return this.close();
        }
      };

      BaseDropdown.prototype.onSelectOption = function(selectionHandler) {
        return this.selectionHandlers.push(selectionHandler);
      };

      BaseDropdown.prototype.offSelectOption = function(selectionHandler) {
        var handlerIndex;
        handlerIndex = this.selectionHandlers.indexOf(selectionHandler);
        if (handlerIndex >= 0) {
          return this.selectionHandlers.splice(handlerIndex, 1);
        }
      };

      BaseDropdown.prototype.removeAllHandlers = function() {
        return this.selectionHandlers = [];
      };

      BaseDropdown.prototype.close = function() {
        if (this.isDisabled()) {
          return void 0;
        }
        this.$menu.hide();
        return this.data.isOpen = false;
      };

      BaseDropdown.prototype.disable = function() {
        this.close();
        this.$el.addClass('b_dropdown-disabled');
        this.$hiddenInput.prop('disabled', true);
        return this.data.isDisabled = true;
      };

      BaseDropdown.prototype.enable = function() {
        this.$el.removeClass('b_dropdown-disabled');
        this.$hiddenInput.prop('disabled', false);
        return this.data.isDisabled = false;
      };

      BaseDropdown.prototype.getOption = function(indexOrElement) {
        var $el, index;
        if (indexOrElement instanceof Option) {
          index = this.data.options.indexOf(indexOrElement);
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
          index = this.$options.index($el);
        }
        return this.getOptionByIndex(index);
      };

      BaseDropdown.prototype.getOptionByIndex = function(optionIndex) {
        if (this.data.options.length > optionIndex) {
          return this.data.options[optionIndex];
        } else {
          return null;
        }
      };

      BaseDropdown.prototype.getSelectedIndex = function() {
        var selectedOption;
        selectedOption = this.getSelectedOption();
        if (selectedOption) {
          return selectedOption.getIndex();
        } else {
          return -1;
        }
      };

      BaseDropdown.prototype.getSelectedLabel = function() {
        var selectedOption;
        selectedOption = this.getSelectedOption();
        if (selectedOption) {
          return selectedOption.getLabel();
        } else {
          return null;
        }
      };

      BaseDropdown.prototype.getSelectedOption = function() {
        return this.data.selectedOption || null;
      };

      BaseDropdown.prototype.getSelectedValue = function() {
        var selectedOption;
        selectedOption = this.getSelectedOption();
        if (selectedOption) {
          return selectedOption.getValue();
        } else {
          return null;
        }
      };

      BaseDropdown.prototype.isDisabled = function() {
        return this.data.isDisabled;
      };

      BaseDropdown.prototype.navigateToLink = function(link) {
        return location.href = link;
      };

      BaseDropdown.prototype.open = function() {
        if (this.isDisabled()) {
          return void 0;
        }
        this.$menu.show();
        return this.data.isOpen = true;
      };

      BaseDropdown.prototype.selectOption = function(indexOrElement, preventEvent) {
        var dropdown, option, selectionHandler, timestamp, _i, _len, _ref, _results;
        dropdown = this;
        option = this.getOption(indexOrElement);
        if (option) {
          timestamp = new Date();
          this.data.selectedOption = option;
          if (!this.opts.staticHeaderText) {
            this.$toggleHeader.empty();
            this.$toggleHeader.html(option.getLabel());
          }
          this.$hiddenInput.val(option.getValue());
          if (!preventEvent) {
            _ref = this.selectionHandlers;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              selectionHandler = _ref[_i];
              _results.push((function(_this) {
                return function(selectionHandler) {
                  return selectionHandler.call(_this, {
                    dropdown: _this,
                    option: option,
                    timestamp: timestamp
                  });
                };
              })(this)(selectionHandler));
            }
            return _results;
          }
        }
      };

      BaseDropdown.prototype.toggle = function() {
        if (this.isOpen()) {
          return this.close();
        } else {
          return this.open();
        }
      };

      BaseDropdown.prototype.isOpen = function() {
        return this.data.isOpen || false;
      };

      BaseDropdown.prototype.destroy = function() {
        return this.unbindEvents();
      };

      return BaseDropdown;

    })();
    return BaseDropdown;
  });

}).call(this);

(function() {


}).call(this);

(function() {


}).call(this);

(function() {
  define('b_dropdown', ['jquery', 'b_dropdown-option', 'b_dropdown-base'], function($, Option, BaseDropdown) {
    return {
      Option: Option,
      BaseDropdown: BaseDropdown
    };
  });

}).call(this);
