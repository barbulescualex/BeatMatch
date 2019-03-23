/*:
 # BeatMatch
 
 A simple and elegant beat matching game
 
 _______________________________________
 
 Welcome to my Beat Match! A game that uses the AVFoundation, Metal and Accelerate frameworks to provide a beatiful audio visual experience.
 
 #### Inspiration:
 
 I consider myself both a programming and music enthusiest, so when I realized I had no clue how music works and is processed in a digital format I knew I had fill that gap in my knowledge.
 
 #### Resources:
 
 All the sounds were created by me, both the instruments and my voice (obviously 😉), the one PNG asset, the restart button, was also created by me.
 
 ________________________________________
 
 #### How To Play:
 
 Tap on the speaker to listen to the beat
 
 When you see the listening... icon start playing back the beat!
 
 Don't like the layout on your midi pad? Just hold down on a button to move it!
 
 
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

