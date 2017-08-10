var exec = require('cordova/exec');

exports.saveText = function(name,value, success, error) {
    exec(success, error, "ModusEchoSwift", "saveText", [name,value]);
};

exports.addContact = function(relationship,name,phone,phoneType, success, error) {
    exec(success, error, "ModusEchoSwift", "save", [relationship,name,phone,phoneType]);
};

exports.removeContact = function(index, success, error) {
    exec(success, error, "ModusEchoSwift", "save", [index]);
};

exports.updateContact = function(index,relationship,name,phone,phoneType, success, error) {
    exec(success, error, "ModusEchoSwift", "save", [index, relationship,name,phone,phoneType]);
};
