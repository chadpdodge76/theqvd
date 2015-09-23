function vmTestFake () {
    module( "Fake tests", {
        setup: function() {
            // prepare something for all following tests
            this.server = sinon.fakeServer.create();
        },
        teardown: function() {
            // clean up after each test
            this.server.restore();
        }
    });

        test("Virtual machine details processing", function() {
            var callback = sinon.spy();

            var fakeValues = WatTests.fakeValues.vm;

            // Number of Assertions we Expect
            expect( Object.keys(fakeValues).length + 2 );

            var fakeResponse = {
                "failures": {},
                "status": 0,
                "rows" : [
                    fakeValues
                ],
                "message": "Successful completion."
            };

            this.server.respondWith(
                "POST", 
                Wat.C.apiUrl + '?sid=' + Wat.C.sid  + '&action=vm_get_details&filters={"id":' + fakeValues.id + '}',
                [
                    200, 
                    { "Content-Type": "application/json" },
                    JSON.stringify(fakeResponse)
                ]
           );

            Wat.Router.watRouter.trigger('route:detailsVM', [fakeValues.id]);        

            // Bind to the change event on the model
            Wat.CurrentView.model.bind('change', callback);

            this.server.respond();

            ok(callback.called, "Server call");

            $.each(fakeValues, function (fieldName, fieldValue) {
                if (typeof fieldValue == 'object') {
                    deepEqual(callback.getCall(0).args[0].attributes[fieldName], fieldValue, "Virtual machine fetching should recover '" + fieldName + "' properly (Random generated: " + JSON.stringify(fieldValue) + ")");
                }
                else {
                    equal(callback.getCall(0).args[0].attributes[fieldName], fieldValue, "Virtual machine fetching should recover '" + fieldName + "' properly (Random generated: " + fieldValue + ")");
                }
            });

            deepEqual(callback.getCall(0).args[0], Wat.CurrentView.model, "Spied result and Backbone model should be equal");
        });
}

function vmTestReal () {
    module( "Real tests", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });

        QUnit.asyncTest("Virtual machine CRUD", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            assertions += Object.keys(WatTests.fakeValues.vm).length * 2; // Create & Update verifications
            assertions +=2; // Create and Delete dependences (User)
            assertions +=2; // Create and Delete dependences (OSF)
            assertions +=2; // Create and Delete dependences (DI)
            assertions +=3; // Create, Update and Delete verifications

            expect(assertions);

            // Move to OSFs section
            Wat.Router.watRouter.trigger('route:listOSF');

            Wat.CurrentView.model = new Wat.Models.OSF();
            delete WatTests.values.osf.id;

            //////////////////////////////////////////////////////////////////
            // Create dependency OSF
            //////////////////////////////////////////////////////////////////
            Wat.CurrentView.createModel(WatTests.values.osf, function (e) { 
                equal(e.retrievedData.status, STATUS_SUCCESS, "OSF created succesfully (" + JSON.stringify(WatTests.values.osf) + ")");

                if(e.retrievedData.status == STATUS_SUCCESS) {
                    WatTests.values.osf.id = e.retrievedData.rows[0].id;
                }
                else {
                    start();
                    return;
                }

                // Move to Disk images section
                Wat.Router.watRouter.trigger('route:listDI');

                Wat.CurrentView.model = new Wat.Models.DI();

                // Create DI associated to the created OSF
                WatTests.values.di.osf_id = WatTests.values.osf.id;
                delete WatTests.values.di.id;

                //////////////////////////////////////////////////////////////////
                // Create dependency DI
                //////////////////////////////////////////////////////////////////
                Wat.CurrentView.createModel(WatTests.values.di, function (e) { 
                    equal(e.retrievedData.status, STATUS_SUCCESS, "DI created succesfully (" + JSON.stringify(WatTests.values.di) + ")");

                    if(e.retrievedData.status == STATUS_SUCCESS) {
                        WatTests.values.di.id = e.retrievedData.rows[0].id;
                    }
                    else {
                        start();
                        return;
                    }

                    // Move to Users section
                    Wat.Router.watRouter.trigger('route:listUser');

                    Wat.CurrentView.model = new Wat.Models.User();
                    delete WatTests.values.user.id;

                    //////////////////////////////////////////////////////////////////
                    // Create Dependency User
                    //////////////////////////////////////////////////////////////////
                    Wat.CurrentView.createModel(WatTests.values.user, function (e) { 
                        equal(e.retrievedData.status, STATUS_SUCCESS, "User created succesfully (" + JSON.stringify(WatTests.values.user) + ")");

                        if(e.retrievedData.status == STATUS_SUCCESS) {
                            WatTests.values.user.id = e.retrievedData.rows[0].id;
                        }
                        else {
                            start();
                            return;
                        }

                        // Move to Virtual machines section
                        Wat.Router.watRouter.trigger('route:listVM');

                        Wat.CurrentView.model = new Wat.Models.VM();

                        // Create VM associated to the created User, OSF and DI
                        WatTests.values.vm.osf_id = WatTests.values.osf.id;
                        WatTests.values.vm.di_tag = WatTests.values.di.version;
                        WatTests.values.vm.user_id = WatTests.values.user.id;
                        delete WatTests.values.vm.id;

                        //////////////////////////////////////////////////////////////////
                        // Create Virtual machine
                        //////////////////////////////////////////////////////////////////
                        Wat.CurrentView.createModel(WatTests.values.vm, function (e) { 
                            equal(e.retrievedData.status, STATUS_SUCCESS, "Virtual machine created succesfully (" + JSON.stringify(WatTests.values.vm) + ")");

                            if(e.retrievedData.status == STATUS_SUCCESS) {
                                WatTests.values.vm.id = e.retrievedData.rows[0].id;
                            }
                            else {
                                start();
                                return;
                            }

                            //////////////////////////////////////////////////////////////////
                            // After create, get list of virtual machines matching by the created name
                            //////////////////////////////////////////////////////////////////
                            WatTests.models.vm = new Wat.Models.VM({
                                id: WatTests.values.vm.id
                            });

                            WatTests.models.vm.fetch({      
                                complete: function () {
                                    $.each (WatTests.fakeValues.vm, function (fieldName) {
                                        var valRetrieved = WatTests.models.vm.attributes[fieldName];

                                        if (fieldName == 'properties' && WatTests.values.vm['__properties__'] != undefined) {
                                            deepEqual(valRetrieved, WatTests.valuesExpected.vm['__properties__'], "Virtual machine field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                        }
                                        else if (WatTests.values.vm[fieldName] != undefined) {
                                            equal(valRetrieved, WatTests.values.vm[fieldName], "Virtual machine field '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                        }
                                        else {
                                            notStrictEqual(WatTests.models.vm.attributes[fieldName], undefined, "Virtual machine field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                        }
                                    });

                                    // Perform changes in testing virtual machine values
                                    performUpdation(WatTests.values.vm, WatTests.updateValues.vm);
                                    WatTests.valuesExpected.vm['__properties__'] = convertPropsToExpected(WatTests.values.vm['__properties__']);

                                    //////////////////////////////////////////////////////////////////
                                    // After get list of virtual machines, update it
                                    //////////////////////////////////////////////////////////////////
                                    Wat.CurrentView.updateModel(WatTests.updateValues.vm, {'id': WatTests.values.vm.id}, function (e) { 
                                        equal(e.retrievedData.status, 0, "Virtual machine updated succesfully (" + JSON.stringify(WatTests.updateValues.vm) + ")");

                                        //////////////////////////////////////////////////////////////////
                                        // After update, get list ofvirtual machines matching by name
                                        //////////////////////////////////////////////////////////////////
                                        WatTests.models.vm.fetch({   
                                            complete: function (e) {
                                                WatTests.values.vm.id = WatTests.models.vm.attributes['id'];
                                                $.each (WatTests.fakeValues.vm, function (fieldName) {
                                                    var valRetrieved = WatTests.models.vm.attributes[fieldName];

                                                    if (fieldName == 'properties' && WatTests.values.vm['__properties__'] != undefined) {
                                                        deepEqual(valRetrieved, WatTests.valuesExpected.vm['__properties__'], "Virtual machine field '" + fieldName + "' retrieved successfully and match with created value (" + JSON.stringify(valRetrieved) + ")");
                                                    }
                                                    else if (WatTests.values.vm[fieldName] != undefined) {
                                                        equal(valRetrieved, WatTests.values.vm[fieldName], "Virtual machine '" + fieldName + "' retrieved successfully and match with created value (" + valRetrieved + ")");
                                                    }
                                                    else {
                                                        notStrictEqual(WatTests.models.vm.attributes[fieldName], undefined, "Virtual machine field '" + fieldName + "' retrieved successfully (" + valRetrieved + ")");
                                                    }
                                                });


                                                //////////////////////////////////////////////////////////////////
                                                // After tests, delete virtual machine
                                                //////////////////////////////////////////////////////////////////
                                                Wat.CurrentView.deleteModel({'id': WatTests.values.vm.id}, function (e) { 
                                                    equal(e.retrievedData.status, 0, "Virtual machine deleted succesfully (ID: " + JSON.stringify(WatTests.values.vm.id) + ")");

                                                    //////////////////////////////////////////////////////////////////
                                                    // After delete virtual machine, delete the dependency user
                                                    //////////////////////////////////////////////////////////////////

                                                    Wat.Router.watRouter.trigger('route:listUser');

                                                    Wat.CurrentView.model = new Wat.Models.User();

                                                    Wat.CurrentView.deleteModel({'id': WatTests.values.user.id}, function (e) { 
                                                        equal(e.retrievedData.status, 0, "User deleted succesfully (ID: " + JSON.stringify(WatTests.values.user.id) + ")");

                                                        //////////////////////////////////////////////////////////////////
                                                        // After delete user, delete the dependency disk image
                                                        //////////////////////////////////////////////////////////////////

                                                        Wat.Router.watRouter.trigger('route:listDI');

                                                        Wat.CurrentView.model = new Wat.Models.DI();

                                                        Wat.CurrentView.deleteModel({'id': WatTests.values.di.id}, function (e) { 
                                                            equal(e.retrievedData.status, 0, "DI deleted succesfully (ID: " + JSON.stringify(WatTests.values.di.id) + ")");

                                                            //////////////////////////////////////////////////////////////////
                                                            // After delete di, delete the dependency osf
                                                            //////////////////////////////////////////////////////////////////

                                                            Wat.Router.watRouter.trigger('route:listOSF');

                                                            Wat.CurrentView.model = new Wat.Models.OSF();

                                                            Wat.CurrentView.deleteModel({'id': WatTests.values.di.osf_id}, function (e) { 
                                                                equal(e.retrievedData.status, 0, "OSF deleted succesfully (ID: " + JSON.stringify(WatTests.values.osf.id) + ")");

                                                                // Unblock task runner
                                                                start();
                                                            }, Wat.CurrentView.model);
                                                        }, Wat.CurrentView.model);
                                                    }, Wat.CurrentView.model);
                                                }, Wat.CurrentView.model);

                                            }
                                        });
                                    }, Wat.CurrentView.model);
                                }
                            });
                        });
                    });
                });
            });
        });
}