

{{flutter_js}}
{{flutter_build_config}}

var loading = document.querySelector('#loading');
loading.textContent = "Running app...";
updateProgress(15);
_flutter.loader.load({   
    onEntrypointLoaded: async function (engineInitializer) {
        loading.textContent = "Running app...";
        updateProgress(50);
        let appRunner = await engineInitializer.initializeEngine();
        updateProgress(80);
        loading.textContent = "Running app...";
        await appRunner.runApp();
        updateProgress(100);
    }
});
