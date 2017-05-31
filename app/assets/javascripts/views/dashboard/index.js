(function(Velum, undefined) {
  var EventBus = Velum.EventBus;
  var MinionPoller = Velum.MinionPoller;

  Velum.Views = Velum.Views || {};

  // Dashboard#index view responsible to render the minions for
  // that specific page. On that page, init() is being called.
  Velum.Views.DashboardIndex = {
    init: function() {
      EventBus.on('minions.polled', this.render.bind(this));
    },

    render: function(e, assignedMinions, unassignedMinions) {
      var rendered = '';

      for (i = 0; i < assignedMinions.length; i++) {
        rendered += this.renderMinion(assignedMinions[i]);
      }

      $(".nodes-container tbody").html(rendered);

      if (unassignedMinions.length > 0 && $('#node-count').length === 0) {
        $('#unassigned_count').html(unassignedMinions.length + ' \
          <strong>new</strong> nodes are available but have not been added to the cluster yet');
      } else {
        $('#unassigned_count').html('');
      }
    },

    // builds html for a specific minion
    renderMinion: function(minion) {
      var statusHtml;
      var checked;
      var masterHtml;

      switch(minion.highstate) {
        case 'not_applied':
          statusHtml = '<i class="fa fa-circle-o text-success fa-2x" aria-hidden="true"></i>';
          break;
        case 'pending':
          statusHtml = '\
            <span class="fa-stack" aria-hidden="true">\
              <i class="fa fa-circle fa-stack-2x text-success" aria-hidden="true"></i>\
              <i class="fa fa-refresh fa-stack-1x fa-spin fa-inverse" aria-hidden="true"></i>\
            </span>';
          break;
        case 'failed':
          statusHtml = '<i class="fa fa-times-circle text-danger fa-2x" aria-hidden="true"></i>';
          break;
        case 'applied':
          statusHtml = '<i class="fa fa-check-circle-o text-success fa-2x" aria-hidden="true"></i>';
          break;
      }

      if ((MinionPoller.selectedMasters && MinionPoller.selectedMasters.indexOf(minion.id) !== -1) || minion.role == 'master') {
        checked = 'checked';
      } else {
        checked = '';
      }
      masterHtml = '<input name="roles[master][]" id="roles_master_' + minion.id +
        '" value="' + minion.id + '" type="radio" disabled="" ' + checked + '>';

      return "\
        <tr> \
          <th>" + minion.id + "</th>\
          <td class='text-center'>" + statusHtml +  "</td>\
          <td>" + minion.fqdn +  "</td>\
          <td>" + (minion.role || '') +  "</td>\
          <td class='text-center'>" + masterHtml + "</td>\
        </tr>";
    }
  };
}(window.Velum = window.Velum || {}));
