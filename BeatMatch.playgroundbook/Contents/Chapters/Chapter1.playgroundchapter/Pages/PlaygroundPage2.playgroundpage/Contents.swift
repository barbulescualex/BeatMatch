/*:
 #### How To Play:
 
 Tap on the speaker to listen to the beat.
 
 ![🔉🔉🔉](speakers.png)
 
 When you see the listening icon start playing back the beat!
 
 ![Listening...](listening.png)
 
 Don't like the layout on your MidiPad? Just hold down a button to move it!
 
 
 #### Difficulty Levels:
 
 .baby - even a baby could win this
 
 .easy - for when it's been a long day reviewing applications 😴
 
 .normal - the standard difficulty level found by studying n users (n=1=me)
 
 .hard - I made all of these up and I still can't win on this mode 🙄
 
 #### Other Inputs:
 
 ❤️ Lives - you can override the default lives (up to 10)
 
 🔉 Listens - you can override the default listens (up to 5)
 
 */

//#-hidden-code
import PlaygroundSupport
//#-end-hidden-code


let game = Game(withDifficulty: /*#-editable-code lives*/.normal/*#-end-editable-code*/,
    withLives: /*#-editable-code lives*/5/*#-end-editable-code*/,
    withListensPerLevel: /*#-editable-code listens*/3/*#-end-editable-code*/)


//#-hidden-code
PlaygroundPage.current.liveView = game
//#-end-hidden-code

