(function($) {
    $.fn.velumAutoload = function() {
        //collect plugins to be loaded in a hashmap
        var plugins = {};
        $("*[data-plugin]").each(function(i, element) {
            var elementPluginsCollection = $(element).data('plugin');
            $.each(elementPluginsCollection, function(i, elementPlugin) {
                if (!plugins.hasOwnProperty(elementPlugin.name)) {
                    plugins[elementPlugin.name] = {
                        instances: [{
                            element: element,
                            options: elementPlugin.options
                        }]
                    }
                } else {
                    plugins[elementPlugin.name].instances.push({
                        element: element,
                        options: elementPlugin.options
                    });
                }
            });
        });
        //loop overs plugins to load script tags for required plugins
        $.each(plugins, function(pluginName, pluginObject) {
            $.each(pluginObject.instances, function(i, pluginInstance) {
                $(pluginInstance.element)[pluginName](pluginInstance.options);
            });
        });
    };
    //Start the plugin
    $(document ).ready(function() {
        $().velumAutoload();
    });
})(jQuery);
