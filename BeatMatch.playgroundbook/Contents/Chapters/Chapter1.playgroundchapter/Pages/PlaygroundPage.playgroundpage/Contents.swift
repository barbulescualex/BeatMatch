/*:
 
 ![title](logo.png)
 
 A simple and elegant beat matching game
 
 _______________________________________
 
 Welcome to BeatMatch! A game that uses the **AVFoundation**, **Metal**, and **Accelerate** frameworks to provide a beatiful audio visual experience.
 
 #### Inspiration:
 
 I consider myself both a programming and music enthusiast, so when I realized I had no clue how music works and is processed in a digital format I knew that I had to fill that gap in my knowledge 😁.
 
 #### Resources:
 
 All the sounds were created by me, both the instruments and my voice (obviously 😉) using GarageBand and a coworker's Blue Yetti microphone. All image assets were created by me using Photoshop. This Playground Book was structured using the Swift Playgrounds Author Template.
 
 ________________________________________
 
 # Audio Visualisation
 
 ![picture of my audio visualizer in action](visualizerDemo.png)
 
 #### What is it?
 
 It is when you generate imagery from an audio signal based on its volume and frequency spectrum as inputs in real time! The added visual input to your senses magnifies the emotional response you receive from the music!
 
 
 ## How did I do it?
 
 First, we start with the problem. You need inputs and an output. The inputs need to be scalar values calculated from the sound that is playing and the output needs to be some sort of graphical representation.
 
 ###### Setup:
 
 The first thing we need to do is set up a tap on the AVAudioEngine's main mixer node. This returns buffer data in the form of an AVAudioPCMBuffer. From the buffer we can get the channel data, pointers to the buffer's audio samples using .floatChannelData on the buffer object. The numbers of pointers we have corresponds to the bufferSize specified in the tap. The larger the buffer size, the more data points we have which leads to better accuracy (but also more load for the CPU to process!).
 
 ###### Inputs:
 
 Now that we have all of this buffer data we want two things from it. The current audio level, and the energy levels between frequencies. This is a lot of math so it only makes sense to use the Accelerate framework for high-performance, energy-effecient CPU computations! For the current audio level, we can use a root means squared operation on the buffer data and linear interpolation between the current and previously calculated points for a smooth range of values (important for the visual rendering). For the frequency intensities, we need to perform a fast fourier transform to get our time domain audio signal into the frequency domain. As a result, we get complex values representing the energy of sound between different frequencies, and phases. The phases can be ignored as we only care about the energies for the height of the frequency lines. But before we can plug in the results from our fast fourier transform as inputs, we need need to convert the results back into the real domain using the formula for the magnitude of a complex number √(a^2+b^2). From here, we have the option to normalize the magnitudes which can be easily done with a vector scalar multiplier function.
 
 ###### Output:
 
 Now that we have solved the problem of getting the inputs, we need our output! Our goal is to get a circle that bounces to the current audio level and lines around it depicting the energy levels between frequencies. While this can be done on the CPU using UIViews and animations, it will completely clog up our main thread. The only solution that makes sense is using the GPU to render the graphics! (If you are wondering how I got Metal working in playgrounds without using projects or workspaces, I compile the library at run time from a string). Using trigonometry, we can set up vertex points around the perimeter of a circle and its origin such that when the points get rendered as triangles, the result is a circle! Our result from the root means squared operation on the buffer data can be used as a scalar uniform input for the GPU to use as a position multiplier in the vertex function! For the frequency lines, we can follow the same sort of logic. We set two vertex points around each perimeter point of the circle; one will stay fixed on the perimeter and the other will take in its respective frequency scalar as a multiplier for its position!
 
 ________________
 
 And that is it! We now have a beautiful audio visualizer to represent our music. I hope you learned something new, I know I sure did 😌. (I am looking forward to convincing my boss that we need Metal Shaders in our app so I can get more practice! 🤓).
 
 Tap the play button to see the visualizer in action through a short and sweet game 😊.
 
 🎮 [Play](@next)
 
 */

