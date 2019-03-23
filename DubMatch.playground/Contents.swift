/*:
 # BeatMatch
 
 A simple and elegant beat matching game
 
 _______________________________________
 
 Welcome to my playground! I present to you a game that uses the AVFoundation, Metal and Accelerate frameworks to provide a beatiful audio visual experience.
 
*/
import PlaygroundSupport

PlaygroundPage.current.liveView = Game(withDifficulty: .baby, withLives: nil, withListensPerLevel: nil)
