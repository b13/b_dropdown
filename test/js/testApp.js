var B;

B = B != null ? B : {};

window.B = B;

require(['jquery', 'b_dropdown'], function($, Dropdown) {
  var initBasedDropdown, initialize;
  initialize = function() {
    return initBasedDropdown();
  };
  initBasedDropdown = function() {
    return B.selectBasedDropdown = new Dropdown($('#selectDropdown'), {
      placeholder: "Please select"
    });
  };
  return $(function() {
    return initialize();
  });
});
