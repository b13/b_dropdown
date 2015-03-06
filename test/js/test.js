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
  var initBaseDropdown, initialize;
  initialize = function() {
    B.DropdownClass = Dropdown;
    return initBaseDropdown();
  };
  initBaseDropdown = function() {
    return B.selectBasedDropdown = new Dropdown($('#selectDropdown'), {
      firstOptionIsPlaceholder: true,
      selectedOption: 4
    });
  };
  return $(function() {
    return initialize();
  });
});
