<html>
  <head>
    <title>{{title}} - tropy</title>
    <link href="/css/style.css" rel="stylesheet" type="text/css">
  </head>

  <body>
    <div id="header">
      <ul>
        <li><a href="/create">create</a></li>
        <li><a href="/random">random</a></li>
      </li>
      <h1 id="title">{{title}}</h1>
    </div>
    <div id="content">
      <div id="editor">{{{content}}}</div>
    </div>
    <script src="/lib/ace/ace.js" type="text/javascript" charset="utf-8"></script>
    <script src="/channel/bcsocket.js"></script>
    <script src="/share/share.js"></script>
    <script src="/share/ace.js"></script>
    <script>
window.onload = function() {
  var editor = ace.edit("editor");
  var title = document.getElementById('title');
  var canon = require("pilot/canon");

  editor.setReadOnly(true);
  editor.session.setUseWrapMode(true);
  editor.setShowPrintMargin(false);

  canon.removeCommand("findnext");
  canon.removeCommand("findprevious");
  canon.removeCommand("find");
  canon.removeCommand("gotoline");

  var getTitle = {{{getTitle}}}

  sharejs.open('{{{docName}}}', 'text', function(error, doc) {
    if (error) {
      console.error(error);
      return;
    }
    doc.attach_ace(editor);
    editor.setReadOnly(false);

    var render = function() {
      var docTitle = getTitle(doc.snapshot);
      title.innerHTML = docTitle;
      document.title = docTitle + ' - tropy';
    };

    window.doc = doc;

    render();
    doc.on('change', render);
  });
};
    </script>
  </body>
</html>  
