
function tryParseJSON(data) {
    var response;
    try
    {
      response = JSON.parse(data);
    }
    catch (err)
    {
       response = {};
    }
    return response;
}

function tryLoader(loader, source, data) {
    loader.setSource(source, data);
    if (loader.status === 3) loader.setSource("ErrorMessage.qml",{text: "QML file load error!" });
}

