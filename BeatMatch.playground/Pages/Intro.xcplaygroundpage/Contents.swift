/*:
 
![title](logo.png)
 
 A simple and elegant beat matching game
 
 _______________________________________
 
 Welcome to Beat Match! A game that uses the AVFoundation, Metal and Accelerate frameworks to provide a beatiful audio visual experience.
 
 #### Inspiration:
 
 I consider myself both a programming and music enthusiest, so when I realized I had no clue how music works and is processed in a digital format I knew I had fill that gap in my knowledge😁.
 
 #### Resources:
 
 All the sounds were created by me, both the instruments and my voice (obviously 😉) using garage band and a coworker's Blue Yetti microphone. All image assets were also created by me using Photoshop. The gif below was made using ezgif.com
 
 ________________________________________
 
 # Audio Visualisation
 
 ![demo of an audio visualizer](visualizerDemo.gif)
 
 #### What is it?
 
 It's when you generate imagery based off music using the music's loudness and frequency spectrum as inputs in real time! The added visual input to your senses magnifies the emotional response you recieve from the music!
 
 
 #### How did I do it?
 
 First we start with the problem. You need an input and an output. The input needs to be numbers calculated from the sound that's playing and the output needs to be some sort of graphical representation.
 
 ###### Setup:
 
 The first thing we need to do is setup a tap on the AVAudioEngine's main mixer node. This returns buffer data in the form of an AVAudioPCMBuffer. From the buffer we can get the channel data, pointers to the buffer's audio samples using .floatChannelData on the buffer object. The numbers of pointers we have corresponds to the bufferSize you specified in the tap. The larger the buffer size the more data points we have which leads to better accuracy (but also more work on the CPU to process!).
 
 ###### Input:
 
 Now that we have all this buffer data we want 2 things from it. The current audio level and the energy levels between frequencies. This is a lot of math so it only makes sense to use Apple's Accelerate framework for high-performance energy-effecient CPU computations! For the current audio level we can use a root means squared operation on the buffer data and linear interpolation between the current and previously calculated point for a smooth range of values (important for the visual rendering). For the frequency intensities we need to perform a Fast Fourier Transform to get our time domain audio signal to the frequency domain. As a result we get complex values representing the energy of sound between different frequencies and phases.The phases can be discarded/ignored as we only care about the energies for the height of the lines. But before we can plug those Fast Fourier Transform results as input we need need to convert the results back into the real domain using the formula for the magnitude of a complex numebr √(a^2+b^2). From here you'll want to potentially normalize the magnitudes which can be easily done with a vector scalar multiplier function.
 
 ###### Output:
 
 Now that we've solved the problem of getting the inputs, we need our output! Our goal is to get a circle that bounces to the current audio level and lines around it depicting the energy levels between frequencies. While this can be done on the CPU using CALayers and animations it will completely clog up our main thread. The only solution that makes sense is using the GPU to render the graphics! (If you're wondering how I got Metal working in playgrounds without using projects or workspaces I simply compile the library at run time from a string!). With basic trigonometry we can setup vertex points around the perimeter of a circle and it's origin such that when the points get rendered as triangles the result is a circle! Our result from the RMS operation on the buffer data can be used a scalar uniform input for the GPU to use as a position multiplier in the shader function! Now for the frequency lines we can follow the same sort of logic. We set two points around the perimeter of the circle, one will stay fixed on the perimeter and the other will take in it's respective frequency scalar from the scalar frequency uniform input!
 
 And that's it! We now have a beatiful audio visualizer to represent your music. I hope you learned something new, I know I sure did 😌. (I'm looking forward to convincing my boss that we need Metal Shaders in our app so I can get more practice!🤓)
 
 Tap the play button to see the visualizer in action through a short and sweet game 😊.

 🎮 [Play](@next)
 
*/

