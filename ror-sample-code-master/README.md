# ror-sample-code
RoR sample code

tazworks_background_check.rb:
Module I used to communicate with taz works api on MinistrySafe project. There you can find methods which generate, send requests and parse responses.

fr folder - folder with files which were used on FormRapid project:
Loader - Class which is used to load generated documents and preview. In case if searched document is not not generated yet the class calls resque worker - DocumentGenerator. DocumentGenerator firstly calls parser to put entered data to document template. Further, using pandoc it generates document of required format. Worker notifies about finishing generation via sockets.

ChargifyEntity  - this is my personal example of concerns. On the project we used Chargify and some entities such as plans, transactions and subscriptions. They should be imported from chargify api. I used ChargifyEntity concern for flexible data update of these entities.

clearbit_manager.rb - Module for better use API clearbit.com and gem 'clearbit'.

Class HTMLToPDFGenerator converts html template to pdf file. Also adds QR code to the generated file

Class AnonymousSurvey adds questions for current account upon adding new events and also sorts and displays answers
