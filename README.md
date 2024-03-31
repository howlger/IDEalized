# IDEalized

![IDEalized splash screen](org.idealized.customization/splash.bmp)

Everything to build IDEalized, an IDE built on a customized
[Eclipse IDE](https://www.eclipse.org/eclipseide/), containing additional plug-ins
and - so far only for Windows - a
[IBM Semeru JDK](https://developer.ibm.com/languages/java/semeru-runtimes/downloads/?os=Windows).

IDEalized was choose as product name and the IDEalized branding was created
in order not to violate any trademarks or licenses. Thanks to all authors and
contributors of the parts IDEalized is made of. You can also use this project to
build your own customized IDE.

To build IDEalized in Eclipse, run the _IDEalized with non-p2_ run configuration.

To build IDEalized on the command line via Maven (if step 1 is skipped, plug-ins
from old-style update sites will be missing):
1.  In `mirror-non-p2/`, run `mvn clean verify`
2.  In the root directory, run `mvn clean verify`