/*:
 #### How To Play:
 
 Tap on the speaker to listen to the beat.
 
 ![🔉🔉🔉](speakers.png)
 
 When you see the listening icon start playing back the beat!
 
 ![Listening...](listening.png)
 
 Don't like the layout on your MidiPad? Just hold down on a button to move it!
 
 
 #### Difficulty Levels:
 
 .baby - even a baby could win this
 
 .easy - for when it's been a long day reviewing applications 😴
 
 .normal - the standard difficulty level found by studying N users (N=1=me)
 
 .hard - I made all of these up and I still can't win on this mode 🙄
 
*/

//#-hidden-code
import PlaygroundSupport

PlaygroundPage.current.liveView = Game(withDifficulty: .baby, withLives: nil, withListensPerLevel: nil)
//#-end-hidden-code

