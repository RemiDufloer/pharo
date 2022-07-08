# How to Use Pharo's Multi-Window IDE

In this Readme we will see how to use **Pharo's** multi-window IDE. We will see how to install it and how to launch it. You will also find all the latest additions here.

This IDE is under development so some features are still to be designed, for example windows built with **Spec** cannot be used as native windows.

## Installation

You need to create a new Pharo 10 image.
In this image you will open iceberg .
When iceberg is opened you will need to right click on pharo and select Repair repository.

When this is done a window will open, click "Clone again this repository in a new location"

Then fill out the form like this:

Owner name RemiDufloer
Project name. pharo
.... ...
Protocol Https


Once this is done you will find yourself with pharo on the branch: Pharo11

right click on the pharo repo and checkout branch. go to origin and select sdlWithMiniWorld. (this may take some time)

then click on checkout (it takes some time).

this is now installed.


## Utilisation

To use multi-window you need to run this code in a playground: 

```Smalltalk
wm := WindowManager new.
wm openNewWindowWithRoot: (ClyFullBrowserMorph onDefaultEnvironment )
```

with this code you have a window manager opened and a browser, if you want other browsers you can open them by pressing CTRL B or execute the second line.
