(function (window) {
    var dom = {
        EXTERNAL_K8S_FQDN_GROUP: '.form-group-external-kubernetes',
        EXTERNAL_K8S_FQDN_INPUT: '#settings_apiserver',
        EXTERNAL_VELUM_FQDN_GROUP: '.form-group-external-velum',
        EXTERNAL_VELUM_FQDN_INPUT: '#settings_dashboard_external_fqdn',
        TRAILING_DOT_K8S_MSG: '.trailing-dot-k8s',
        TRAILING_DOT_VELUM_MSG: '.trailing-dot-velum',
        BOOTSTRAP_BTN: '#bootstrap'
    };

    function proxy(validations) {
        return {
            valid: true,
            set: function(val) {
                this.valid = val;
                this.validations();
            },
            validations: validations
        };
    };

    /** Using FQDNs with a trailing dot causes problems in:
     * - velum: can not connect to the master server in app/controllers/oidc_controller.rb
     * - dex: can not connect to the master server
     * These functions will flag a value that ends in a trailing dot as an error.
     */
    function BootstrapSettings(el) {
        this.$el = $(el);
        k8sValidations = function() {
            this.displayError(dom.EXTERNAL_K8S_FQDN_GROUP, dom.TRAILING_DOT_K8S_MSG, this.$k8s.valid);
            this.validateSubmit();
        };
        velumValidations = function() {
            this.displayError(dom.EXTERNAL_VELUM_FQDN_GROUP, dom.TRAILING_DOT_VELUM_MSG, this.$velum.valid);
            this.validateSubmit();
        };
        // Instead of using a Proxy(), uses a simple setter that will trigger
        // the validations callback function, as Proxy is not compatible with
        // phantomJs (no support for JS6).
        this.$k8s = proxy(k8sValidations.bind(this));
        this.$velum = proxy(velumValidations.bind(this));

        this.$k8sFqdnGroup = this.$el.find(dom.EXTERNAL_K8S_FQDN_GROUP);
        this.$k8sFqdnInput = this.$el.find(dom.EXTERNAL_K8S_FQDN_INPUT);

        this.$velumFqdnGroup = this.$el.find(dom.EXTERNAL_VELUM_FQDN_GROUP);
        this.$velumFqdnInput = this.$el.find(dom.EXTERNAL_VELUM_FQDN_INPUT);

        this.events();
    };

    BootstrapSettings.prototype.events = function() {
        this.$el.on('input', dom.EXTERNAL_K8S_FQDN_INPUT, this.onK8sFqdnInput.bind(this));
        this.$el.on('input', dom.EXTERNAL_VELUM_FQDN_INPUT, this.onVelumFqdnInput.bind(this));
    };

    BootstrapSettings.prototype.onK8sFqdnInput = function (e) {
        this.$k8s.set(!this.$k8sFqdnInput.val().endsWith("."));
    };

    BootstrapSettings.prototype.onVelumFqdnInput = function (e) {
        this.$velum.set(!this.$velumFqdnInput.val().endsWith("."));
    };

    BootstrapSettings.prototype.displayError = function(errorGroup, errorMsg, predicate) {
        $(errorGroup).toggleClass("has-error", !predicate);
        $(errorMsg).toggleClass("hidden", predicate);
    };

    BootstrapSettings.prototype.validateSubmit = function() {
        $(dom.BOOTSTRAP_BTN).prop('disabled', !(this.$k8s.valid && this.$velum.valid));
    };

    window.BootstrapSettings = BootstrapSettings;
}(window));
