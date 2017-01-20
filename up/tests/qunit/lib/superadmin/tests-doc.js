function languageDocTest() {
    module( "Documentation tests", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });
    
        test("Screens Info modal doc", function() {
            // Number of Assertions we Expect
            var assertions = 0;
            
            assertions += Object.keys(Up.I.docSections).length * DOC_AVAILABLE_LANGUAGES.length;
            //expect(assertions);
            
            stop(assertions-1);
            
            $.each(DOC_AVAILABLE_LANGUAGES, function (iLan, lan) {
                $.each (Up.I.docSections, function (iSection, section) {
                    Up.D.fillTemplateString = function (string, target, toc, docParams) {
                        notEqual(string, null, 'Documentation section "' + docParams.sectionId + '" was found in guide "' + docParams.guide + '"');
                        start();
                    };
                    
                    Up.D.fillDocSection(section.guide, section[lan] + '', false, APP_PATH);
                });
            });
        });
}