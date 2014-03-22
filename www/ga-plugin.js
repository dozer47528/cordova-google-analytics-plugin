cordova.define("cc.dozer.cordova.ga-plugin.ga-plugin", function(require, exports, module) {
    var exec = require('cordova/exec');
    var GaPlugin = function() {};

    GaPlugin.prototype.init = function(success, fail, id, period) {
        cordova.exec(success, fail, 'GaPlugin', 'initGA', [id, period]);
    };

    GaPlugin.prototype.sendEvent = function(success, fail, category, eventAction, eventLabel, eventValue) {
        if (!eventValue) {
            eventValue = 0
        }
        cordova.exec(success, fail, 'GaPlugin', 'sendEvent', [category, eventAction, eventLabel, eventValue]);
    };

    GaPlugin.prototype.sendView = function(success, fail, pageURL) {
        cordova.exec(success, fail, 'GaPlugin', 'sendView', [pageURL]);
    };

    GaPlugin.prototype.setCustomDimension = function(success, fail, index, value) {
        cordova.exec(success, fail, 'GaPlugin', 'setCustomDimension', [index, value]);
    };

    GaPlugin.prototype.setCustomMetric = function(success, fail, index, value) {
        cordova.exec(success, fail, 'GaPlugin', 'setCustomMetric', [index, value]);
    };

    GaPlugin.prototype.sendTiming = function(success, fail, category, time, name, label) {
        cordova.exec(success, fail, 'GaPlugin', 'sendTiming', [category, time, name, label]);
    };

    GaPlugin.prototype.sendException = function(success, fail, message, fatal) {
        cordova.exec(success, fail, 'GaPlugin', 'sendException', [message, fatal]);
    };

    var gaPlugin = new GaPlugin();
    module.exports = gaPlugin;
});
