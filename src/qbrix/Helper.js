
function parseJSON(data) {
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
