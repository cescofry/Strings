###Strings
=======

Strings is an utility to transform and manage the diffrent localization files from and to an iOS project and an Android project.
The obejctive-C project has 2 targets. They are meant for managing strings through an GUI interface as well as a command line one.

The core library at the moment is 
- Transforming both iOS and Android translation files into Dictionaries
- Grouping together the same transaltions file from different language folders
- Grouping together iOS and Android files with the same keys in it (match >= 5).
- On conversion between the platforms will also take care of formats specific changes (%@ -> $1@ ...)


###Documentations
Documentation is a bit behind, also the code is purely commented. I promise to add doxigen as soon as possible.
There are however only 4 classes worth mentioning, which are the one doing mosto fo the heavy lifting to aggregate and translate the files.
Those are:

- ZFLangFile - Rapresentation of a language file, contaninng all the languages translations for both iOS and Android
- ZFStringScanner - goes through all the forlders form a given root one and generates the ZFLangFiles
- ZFStringsConverter - Feed with a URL of a string file will generate the dicotionary of transaltions. Also will reconvert a dictionary to iOS or Android file given a URL. It is used by ZFLanfFile to generate the translations
- ZFUtils - Singletons with commons tasks. Pretty empty at the moment


###Tests
Tests are a bit behind
