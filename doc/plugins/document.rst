``Document`` plugin
===================

This plugin uses heuristics to determine alternate urls that point
to the same content. The document plugin needs support form the store
backend.

Interface Overview
------------------

The backend has to take the uris provided by the document plugin and
retrieve ``store.search`` should use this information to retrieve
annotations if the searched uri matches any of the document uris.
See the example code in

Potential Problems
------------------

Once a wrong equivalence is created between two URIs, there is
(currently) no way to undo that equivalence.
