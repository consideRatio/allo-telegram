# Messaging service

This is an Alloverse application. It is a program that when run can exposes
itself to an Alloplace (Alloverse world server), as a 3D object users can
interact with. The idea is that it should help users in the Alloplace write text
messages that are previewed and delivered by voice to each other in various
ways.

[Read about making Alloverse apps here](https://docs.alloverse.com/).

## Developing

The application source code is in the `lua/` folder.

To start the app and connect it to an Alloplace for testing, run

```
./allo/assist run alloplace://nevyn.places.alloverse.com
```

## Initial development goals

### Goal 1

A button plays a fixed sound.

- [x] UI: A play button.
- [x] Register fixed audio asset file.
- [x] Let the play button play a fixed audio asset.
  - The Button component has [an example](https://github.com/alloverse/alloui-lua/blob/3bcc68810420dbdc1afecf681a59e484be86acbb/lua/alloui/views/button.lua#L86-L104)
  - `playSound` is is part of the View class

### Goal 2

A button converts text input to sound, then plays the sound.

- [ ] UI: Make the play button create a popup
- [ ] UI: A popup that includes:
  - a text input field
  - a process & preview button
  - an exit button.
- [ ] Process & preview button interaction:
  - [ ] Convert text to speech into a .wav file (using external executable)
  ```
  tts --text "Hi everyone, this is quite crazy!" --out_path output.wav
  ```
  - [ ] Convert .wav file into .ogg file (using external executable)
  ```
  ffmpeg -i output.wav -acodec libvorbis output.ogg
  ```
  - [ ] Register an audio asset
  - [ ] Play registered audio asset

### Goal 3

Become aware about activities of the world entities that has an identity.

- [ ] Repeatedly poll world state
  - App.schedule_action
  - client.state.entities: any entity with identity is a human
- [ ] Let a function trigger on
  - [ ] a user joined
  - [ ] a user left

### Goal 4

Let a user send a message to a recipient.

- [ ] Create a send message UI
  - [ ] Only accept exact messages
  - [ ] Support the following delivery options:
    - [ ] as soon as recipient is available
    - [ ] as soon as sender leaves server
- [ ] Create a receive message UI
  - [ ] A popup saying a message is received from sender
  - [ ] A play button and a close button
