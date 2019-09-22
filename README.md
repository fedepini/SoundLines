# SoundLines

SoundLines is an accessible iOS app with the aim of teaching blind or visually impaired children basic geometry concepts. It is designed as a game where the user has to connect a kitten to a cat following a line, whose direction and shape changes in the different levels, guided by sound spatialization, VoiceOver instructions and different sounds.

## Built With

* [Swift](https://www.apple.com/swift/) - The programming language used
* [AudioKit](https://audiokit.io/) - Framework used to manage sound elements

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

* a MacOS device - Necessary to run Xcode
* an iOS device - Necessary to test VoiceOver interactions
* [VoiceOver](https://www.apple.com/accessibility/) activated - iOS's accessibily tool for screen reading
* [Xcode](https://developer.apple.com/xcode/) - Apple's IDE for app development
* [AudioKit](https://audiokit.io/) - Framework used to manage sound elements

### Installing

1. [Download Xcode](https://apps.apple.com/it/app/xcode/id497799835?mt=12) on your MacOS device and install it

2. Open Xcode and clone this GitHub repository. You can do it from the navigation bar:

```
Source Control -> Clone... -> Paste https://github.com/fedepini/SoundLines -> Clone
```

or from command line:

```
$ git clone https://github.com/fedepini/SoundLines
```

3. Open the cloned repository on Xcode.

4. Install AudioKit. You can do it with CocoaPods, as recommended from [AudioKit's own guide](https://audiokit.io/downloads/).
    * Install CocoaPods following [their guide](https://guides.cocoapods.org/using/getting-started.html).
    * Update your Podfile pasting

    ```
    pod 'AudioKit', '~> 4.6.4'
    ```
    * Execute:

    ```
    $ pod install
    ```

5. Done! You can try SoundLines on Xcode iOS simulators or, for a complete test, on an iOS device with VoiceOver activated. To activate VoiceOver on your device go to:

```
Settings -> General - Accessibility -> VoiceOver
```


## Authors

* **Federico Pini** - [GitHub](https://github.com/fedepini)
* **Massimo Petrogalli** - [GitHub](https://github.com/MassiPetro)

## Acknowledgments

* **Prof. Sergio Mascetti** - [University of Milan](https://homes.di.unimi.it/mascetti/Sergio_Mascetti_-_home_page/Home.html)
* **Diane Brauner** - [Paths to Technology](https://www.perkinselearning.org/users/diane-brauner)
* Kitten and cat icons made by [Freepik](https://www.freepik.com/home) from [www.flaticon.com](https://www.flaticon.com)
