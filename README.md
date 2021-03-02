README

This project was implemented in the course of a university project in iOS development.

Programmed for iPhone12/iPhone12 Pro
Pod installed: FSCalendar (needs installation through bash on opening on new device as far as I know)
Installation: bash -> cd (filepath) -> pod install
Link: https://github.com/WenchaoD/FSCalendar

Known problems:

-In Dark-Mode: Calendar Dates of actual month are black - background is too

-On startup without pods installed the build will fail since FSCalendar is not installed

-Table view does not refresh after adding a plant, needs app restart
Tried to reload TV data in viewDidLoad(), viewDidAppear() and unwind(), no options work for whatever reason
-> same problem with CalendarView (calendar + tableview)

-Add image from camera does not work (but is still in the app), adding images from gallery works perfectly fine


Possible further steps:

-Extending watering cycles
So far, only the next watering date is added


Possible errors on build and startup on Swift Emulator:

Source type camera is not supported on Emulator -> actual device required for testing, should work
