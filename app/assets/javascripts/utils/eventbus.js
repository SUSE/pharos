(function(Velum, undefined) {
  // Reusing jQuery object to build an empty one
  // that inherits .on/.off/.trigger methods to work
  // with events
  Velum.EventBus = $({});
}(window.Velum = window.Velum || {}));
