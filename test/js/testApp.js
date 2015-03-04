var B;

B = B != null ? B : {};

window.B = B;

require(['jquery', 'b_dropdown'], function($, Dropdown) {
  var initBaseDropdownWithDynamicHeader, initBaseDropdownWithStaticHeader, initSelectBasedDropdown, initialize;
  initialize = function() {
    initBaseDropdownWithStaticHeader();
    initBaseDropdownWithDynamicHeader();
    return initSelectBasedDropdown();
  };
  initBaseDropdownWithStaticHeader = function() {
    return B.baseDropdownStaticHeader = new Dropdown($('#baseDropdown-staticHeader'), {
      staticHeader: "Base Dropdown"
    });
  };
  initBaseDropdownWithDynamicHeader = function() {
    return B.baseDropdownDynamicHeader = new Dropdown($('#baseDropdown-dynamicHeader'), {
      placeholder: "Placeholder Text"
    });
  };
  initSelectBasedDropdown = function() {
    return B.selectBasedDropdown = new Dropdown($('#selectDropdown'), {
      placeholder: "Please select"
    });
  };
  return $(function() {
    return initialize();
  });
});
