var B;

B = B != null ? B : {};

window.B = B;

require(['jquery', 'b_dropdown'], function($, Dropdown) {
  var initBaseDropdownWithDynamicHeader, initBaseDropdownWithStaticHeader, initialize;
  initialize = function() {
    initBaseDropdownWithStaticHeader();
    return initBaseDropdownWithDynamicHeader();
  };
  initBaseDropdownWithStaticHeader = function() {
    return B.baseDropdownStaticHeader = new Dropdown.BaseDropdown($('#baseDropdown-staticHeader'), {
      staticHeaderText: "Base Dropdown"
    });
  };
  initBaseDropdownWithDynamicHeader = function() {
    return B.baseDropdownDynamicHeader = new Dropdown.BaseDropdown($('#baseDropdown-dynamicHeader'), {
      placeholderHeaderText: "Placeholder Text"
    });
  };
  return $(function() {
    return initialize();
  });
});
