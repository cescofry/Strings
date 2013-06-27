###Strings
=======

Strings is an utility to transform and manage the diffrent localization files from and to an iOS project and an Android project.<br>
The obejctive-C project has 2 targets. They are meant for managing strings through an GUI interface as well as a command line one.<br>

The core library at the moment is 
- Transforming both iOS and Android translation files into Dictionaries
- Grouping together the same transaltions file from different language folders
- Grouping together iOS and Android files with the same keys in it (match >= 5).
- On conversion between the platforms will also take care of format specific convertions (%@ -> $1@ ...)


###Documentations
There are 4 classes part of the core library, which are the one doing most of the heavy lifting to aggregate and translate the files.<br>
Those are:<br>

- ZFLangFile - Rapresentation of a language file, contaninng all the languages translations for both iOS and Android
- ZFStringScanner - goes through all the forlders form a given root one and generates the ZFLangFiles
- ZFStringsConverter - Feed with a URL of a string file will generate the dicotionary of transaltions. Also will reconvert a dictionary to iOS or Android file given a URL. It is used by ZFLanfFile to generate the translations
- ZFUtils - Singletons with commons tasks. Pretty empty at the moment

Doxygen documentation is present for those 4 classes. The rest of the documentation will come later.

###Tests
Tests are a bit behind

### Aknolegment
My background comes from iOS developemnt. In that sense I feel pretty confident with the import/export and translation of the files. However this project could really use some help from some more experienced Mac OS X developers to address the user interface, as well as some Android developers ot check the format conversion and the parsing of xml files.<br>
At this stage the basic for file conversion is at a good stage. Most important features to be implemented are the keeping the order of the keys during parsing comapred with original files, and consequently tracking and parsing of the comments inside the files (at the moment both ignored). Also the Andorid xml string elements sometimes contain a format attribute that is ignored from the covnertion and later on the parsing as well.<br>
