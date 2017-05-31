(function(Velum, undefined) {
  var EventBus = Velum.EventBus;
  var MinionPoller = Velum.MinionPoller;

  Velum.Views = Velum.Views || {};

  // Setup#discovery view responsible to render the minions for
  // that specific page. On that page, init() is being called.
  Velum.Views.SetupDiscovery = {
    init: function() {
      EventBus.on('minions.polled', this.render.bind(this));
    },

    checkBootstrapButton: function(minions) {
      // disable bootstrap button if there are no minions
      if (minions.length === 0) {
        $('#bootstrap').prop('disabled', true);
      } else {
        $('#bootstrap').prop('disabled', false);
      }
    },

    render: function(e, assignedMinions, unassignedMinions) {
      var rendered = '';

      var minions = assignedMinions.concat(unassignedMinions);

      for (i = 0; i < minions.length; i++) {
        rendered += this.renderMinion(minions[i]);
      }

      $('.nodes-container tbody').html(rendered);

      this.checkBootstrapButton(minions);

      if (unassignedMinions.length > 0 && $("#node-count").length > 0) {
        $('#node-count').text(unassignedMinions.length +  ' nodes found');
      }
    },

    // builds html for a specific minion
    renderMinion: function(minion) {
      var masterHtml;
      var checked;

      if (MinionPoller.selectedMasters && MinionPoller.selectedMasters.indexOf(minion.id) !== -1) {
        checked = 'checked';
      } else {
        checked = '';
      }
      masterHtml = '<input name="roles[master][]" id="roles_master_' + minion.id +
        '" value="' + minion.id + '" type="radio" ' + checked + '>';

      return "\
        <tr> \
          <th>" + minion.id + "</th>\
          <td>" + minion.fqdn + "</td>\
          <td class='text-center'>" + masterHtml + "</td>\
        </tr>";
    }
  };
}(window.Velum = window.Velum || {}));
