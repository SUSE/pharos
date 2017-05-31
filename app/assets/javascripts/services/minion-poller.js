(function(Velum, undefined) {
  var EventBus = Velum.EventBus;

  // MinionPoller will be responsible to only fetch minions data
  // and notify whoever is interested on it through Velum.EventBus
  var MinionPoller = Velum.MinionPoller = {
    poll: function() {
      this.request();
    },

    request: function() {
      $.ajax({
        url: $('.nodes-container').data('url'),
        dataType: "json",
        cache: false,
      }).success(function(data) {
          MinionPoller.selectedMasters = $('input[name="roles[master][]"]:checked').map(function() {
            return parseInt($( this ).val());
          }).get();

          // In discovery, the minions to be rendered are unassigned, while on the
          // dashboard we don't want to render unassigned minions but we still
          // want to account for them.
          var assignedMinions = data.assigned_minions || [];
          var unassignedMinions = data.unassigned_minions || [];

          EventBus.trigger('minions.polled', [assignedMinions, unassignedMinions]);
      }).always(function() {
        // always schedule another request after the last one was finished
        // being either success or fail
        setTimeout(MinionPoller.poll.bind(MinionPoller), 5000);
      });
    },
  };

}(window.Velum = window.Velum || {}));
