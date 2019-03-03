# IDEalized

![IDEalized splash screen](org.idealized.customization/splash.bmp)

Everything to build IDEalized, an IDE built on a customized
[Eclipse IDE](https://www.eclipse.org/eclipseide/), containing additional plug-ins
and - so far only for Windows - the
[OpenJ9 OpenJDK 11](https://adoptopenjdk.net/?variant=openjdk11&jvmVariant=openj9).

IDEalized was choose as product name and the IDEalized branding was created
in order not to violate any trademarks or licenses. Thanks to all authors and
contributors of the parts IDEalized is made of. You can use this project to
build your own customized IDE.

To build IDEalized in Eclipse, run the _IDEalized with non-p2_ run configuration.

To build IDEalized on the command line via Maven (if step 1 is skipped, plug-ins
that do not have a p2 update site will be missing):
1.  `mvn clean verify -P mirror-non-p2`
2.  `mvn clean verify`