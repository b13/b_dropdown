(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define('b_dropdown', ['jquery'], function($) {
    var Dropdown, Option, __setElementAttribute;
    Dropdown = (function() {
      Dropdown.prototype.defaultOpts = {
        closeOnClickOutside: true,
        closeOnSelect: true
      };

      function Dropdown(el, opts) {
        this.toggle = __bind(this.toggle, this);
        this.select = __bind(this.select, this);
        this.resetSelection = __bind(this.resetSelection, this);
        this.open = __bind(this.open, this);
        this.close = __bind(this.close, this);
        this._handleWindowClick = __bind(this._handleWindowClick, this);
        this._handleOptionSelection = __bind(this._handleOptionSelection, this);
        var $el, $replacement, attribute, attrs, isWrappedByForm, jSONOptions, _i, _len;
        $el = $(el);
        isWrappedByForm = Boolean($el.closest('form').length);
        this.opts = $.extend({}, this.defaultOpts, opts || {});
        if (this.opts.options) {
          jSONOptions = this.opts.options;
        }
        if ($el.prop('tagName') === 'SELECT') {
          attrs = $el.prop('attributes');
          if (!this.opts.name) {
            this.opts.name = $el.attr('name');
          }
          if (!jSONOptions) {
            jSONOptions = this._getJSONDataFromSelectStructure($el);
          }
          $replacement = $('<div></div>');
          $el.after($replacement);
          $el.remove();
          $el = $replacement;
          for (_i = 0, _len = attrs.length; _i < _len; _i++) {
            attribute = attrs[_i];
            __setElementAttribute($el, attribute);
          }
          $el.addClass('b_dropdown');
        }
        if (jSONOptions) {
          $el.empty();
          this._renderInnerHTMLFromJSON($el, jSONOptions, isWrappedByForm);
        }
        this.$el = $el;
        if (!this.$toggleHeader) {
          this.$toggleHeader = this.$el.find('.b_dropdown-toggle');
        }
        if (!this.$menu) {
          this.$menu = this.$el.find('ul');
        }
        if (!this.$options) {
          this.$options = this.$menu.children('li');
        }
        if (!this.$hiddenInput) {
          this.$hiddenInput = this.$el.find('input[type=hidden]');
        }
        if (this.opts.name) {
          this.$hiddenInput.attr('name', this.opts.name);
        }
        this.selectionHandlers = [];
        this.data = {
          isOpen: false,
          isDisabled: false,
          ddOptions: this._initDropdownOptions()
        };
        if (this.opts.staticHeader) {
          this.$toggleHeader.html('<span>' + this.opts.staticHeader + '</span>');
        }
        if ((this.opts.selectedOption != null) && this.opts.selectedOption >= 0) {
          this.select(this.opts.selectedOption);
        } else {
          this.select(-1);
        }
        this.bindEvents();
      }

      Dropdown.prototype._renderInnerHTMLFromJSON = function($targetEl, jSONOptions, isWrappedByForm) {
        var $menuWrap, $newLink, $newOptionEl, isLink, label, option, value, _i, _len;
        this.toggleHeader = $('<button class="b_dropdown-toggle"></button>');
        $targetEl.append(this.toggleHeader);
        $menuWrap = $('<div class="b_dropdown-menuWrap"></div>');
        $targetEl.append($menuWrap);
        this.$menu = $('<ul></ul>');
        $menuWrap.append(this.$menu);
        for (_i = 0, _len = jSONOptions.length; _i < _len; _i++) {
          option = jSONOptions[_i];
          if (typeof option === 'string') {
            label = option;
            value = option;
          } else {
            value = option.value;
            label = option.label || value;
            isLink = option.isLink || false;
          }
          $newOptionEl = $('<li data-value="' + value + '"></li>');
          this.$menu.append($newOptionEl);
          if (isLink) {
            $newLink = $('<a href="' + (option.href || "") + '"></a>');
            $newOptionEl.append($newLink);
          }
          $newOptionEl.text(label);
        }
        this.$hiddenInput = $('<input type="hidden"></input>');
        $targetEl.append(this.$hiddenInput);
        if (isWrappedByForm) {
          return this.$hiddenInput.wrap('<form></form>');
        }
      };

      Dropdown.prototype._getJSONDataFromSelectStructure = function($selectElement) {
        var $optionsEls, optionsArray;
        optionsArray = [];
        $optionsEls = $selectElement.children('option');
        $optionsEls.each(function() {
          var $link, $option, nextOptionObject;
          nextOptionObject = {};
          $option = $(this);
          $link = $option.children('a');
          nextOptionObject.label = $option.text() || "";
          nextOptionObject.value = $option.val() || nextOptionObject.label;
          if ($link.length) {
            nextOptionObject.isLink = true;
            nextOptionObject.href = $link.attr('href');
          }
          return optionsArray.push(nextOptionObject);
        });
        return optionsArray;
      };

      Dropdown.prototype._initDropdownOptions = function() {
        var ddOptions, dropddown;
        dropddown = this;
        ddOptions = [];
        this.$options.each(function() {
          return ddOptions.push(new Option(dropddown, this));
        });
        return ddOptions;
      };

      Dropdown.prototype.bindEvents = function() {
        this.$toggleHeader.on('click', this.toggle);
        this.$options.on('click', this._handleOptionSelection);
        return $(window).on('click', this._handleWindowClick);
      };

      Dropdown.prototype.unbindEvents = function() {
        this.$toggleHeader.off('click', this.toggle);
        return $(window).off('click', this._handleWindowClick);
      };

      Dropdown.prototype._handleOptionSelection = function(evt) {
        var optionIndex;
        if (!this.isDisabled()) {
          evt.preventDefault();
          optionIndex = this.$options.index($(evt.currentTarget));
          this.select(optionIndex);
          if (this.opts.closeOnSelect) {
            return this.close();
          }
        }
      };

      Dropdown.prototype._handleWindowClick = function(evt) {
        if (!this.isDisabled() && this.isOpen() && this.opts.closeOnClickOutside && !$.contains(this.$el.get(0), evt.target)) {
          return this.close();
        }
      };

      Dropdown.prototype.onSelectOption = function(selectionHandler) {
        return this.selectionHandlers.push(selectionHandler);
      };

      Dropdown.prototype.offSelectOption = function(selectionHandler) {
        var handlerIndex;
        handlerIndex = this.selectionHandlers.indexOf(selectionHandler);
        if (handlerIndex >= 0) {
          return this.selectionHandlers.splice(handlerIndex, 1);
        }
      };

      Dropdown.prototype.removeAllHandlers = function() {
        return this.selectionHandlers = [];
      };

      Dropdown.prototype.close = function() {
        if (this.isDisabled()) {
          return void 0;
        }
        this.$menu.hide();
        return this.data.isOpen = false;
      };

      Dropdown.prototype.disable = function() {
        this.close();
        this.$el.addClass('b_dropdown-disabled');
        this.$hiddenInput.prop('disabled', true);
        return this.data.isDisabled = true;
      };

      Dropdown.prototype.enable = function() {
        this.$el.removeClass('b_dropdown-disabled');
        this.$hiddenInput.prop('disabled', false);
        return this.data.isDisabled = false;
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
          index = this.$options.index($el);
        }
        return this.getOptionByIndex(index);
      };

      Dropdown.prototype.getOptionByIndex = function(optionIndex) {
        if (this.data.ddOptions.length > optionIndex) {
          return this.data.ddOptions[optionIndex];
        } else {
          return null;
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
          return null;
        }
      };

      Dropdown.prototype.getSelectedOption = function() {
        return this.data.selectedOption || null;
      };

      Dropdown.prototype.getSelectedValue = function() {
        var selectedOption;
        selectedOption = this.getSelectedOption();
        if (selectedOption) {
          return selectedOption.getValue();
        } else {
          return null;
        }
      };

      Dropdown.prototype.isDisabled = function() {
        return this.data.isDisabled;
      };

      Dropdown.prototype.navigateToLink = function(link) {
        return location.href = link;
      };

      Dropdown.prototype.open = function() {
        if (this.isDisabled()) {
          return void 0;
        }
        this.$menu.show();
        return this.data.isOpen = true;
      };

      Dropdown.prototype.resetSelection = function() {
        this.data.selectedOption = void 0;
        this.$hiddenInput.val('');
        if (!this.opts.staticHeader) {
          this.$toggleHeader.empty();
          return this.$toggleHeader.html(this.opts.placeholder || "");
        }
      };

      Dropdown.prototype.select = function(indexOrElement, preventEvent) {
        var option, selectionHandler, timestamp, _fn, _i, _len, _ref;
        option = this.getOption(indexOrElement);
        if (option) {
          timestamp = new Date();
          this.data.selectedOption = option;
          if (!this.opts.staticHeader) {
            this.$toggleHeader.empty();
            this.$toggleHeader.html(option.getLabel());
          }
          this.$hiddenInput.val(option.getValue());
          if (!preventEvent) {
            _ref = this.selectionHandlers;
            _fn = (function(_this) {
              return function(selectionHandler) {
                return selectionHandler.call(_this, {
                  dropdown: _this,
                  option: option,
                  timestamp: timestamp
                });
              };
            })(this);
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              selectionHandler = _ref[_i];
              _fn(selectionHandler);
            }
          }
          if (option.isLink && !this.opts.preventLinkNavigation) {
            return this.navigateToLink(option.href);
          }
        } else {
          return this.resetSelection();
        }
      };

      Dropdown.prototype.toggle = function() {
        if (this.isOpen()) {
          return this.close();
        } else {
          return this.open();
        }
      };

      Dropdown.prototype.isOpen = function() {
        return this.data.isOpen || false;
      };

      Dropdown.prototype.destroy = function() {
        this.enable();
        return this.unbindEvents();
      };

      return Dropdown;

    })();
    Option = (function() {
      function Option(dropdown, option) {
        var $linkEl;
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
        $linkEl = this.$el.find('a');
        this.isLink = $linkEl.length ? true : false;
        this.href = $linkEl.attr('href');
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
    __setElementAttribute = function($el, attribute) {
      if (attribute.nodeName !== 'name') {
        return $el.attr(attribute.nodeName, attribute.value);
      }
    };
    return Dropdown;
  });

}).call(this);
