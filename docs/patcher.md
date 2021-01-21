Patcher schema:
1. Each file to be patched, including manifest, has a filename and data structure that the filename is loaded into.
2. The patcher manifest.json contains a list of classes and the url in which the classes' files will be downloaded from.
3. Currently does not support filename aliasing and multiple filenames per class. The former can be implemented with an additional "alias" parameter in manifest.json and the latter can be implemented by changing the filename and data structures to a nested hash, or arrays.

Patcher logic:
1. Patcher requests versions.json and checks to see if latest ver > current ver stored in manifest. If there is, requests champions.json from the new version's url.
2. If no error, record the new file and update the version number in manifest. If received nothing from the request, log error and roll back all changes. Don't update manifest.
3. Patcher calls reload method for each class, which refreshes data structures for its files. Files are parsed into data structures once during runtime and during each reload, rather than having to read from the file repeatedly for efficiency.
4. When adding new dependent file structures in classes with a reload method, ensure that those file structures are reloaded accordingly.

Suggestions:
Refactor Patcher to be its own library as Data Dragon
examine how to pull champion id from champion.json itself and compare the amount of time vs pulling id from its own hash
