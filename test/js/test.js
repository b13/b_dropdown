require.config({
  paths: {
    b_dropdown: "contrib/b_dropdown",
    jquery: "contrib/jquery",
    requirejs: "contrib/require",
    testApp: "testApp"
  },
  packages: []
});

define("config", function(){});


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
    return B.baseDropdownStaticHeader = new Dropdown($('#baseDropdown-staticHeader'), {
      staticHeaderText: "Base Dropdown"
    });
  };
  initBaseDropdownWithDynamicHeader = function() {
    return B.baseDropdownDynamicHeader = new Dropdown($('#baseDropdown-dynamicHeader'), {
      placeholderHeaderText: "Placeholder Text"
    });
  };
  return $(function() {
    return initialize();
  });
});
