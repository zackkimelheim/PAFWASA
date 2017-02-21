  P   ersonal
  A   assistant
  F   or
  W   eather
  A   nd
  S   tyle 
  A   dvice

  Link to Project: http://zack-physical-computing.blogspot.com/2016/03/midterm-project-pafwasa.html

Haven't you ever woken up in the morning, opened up your closet and thought what you were going to wear? You spend 15 minutes of your morning standing and staring at your clothes, wondering what you are going to put on. And THEN, after you put clothes on, you realize you forgot to check the weather to make sure your dress attire coincides with this extremely inconsistent New York City weather. And upon checking, you realize it is scorching hot out (although mid-February) and you have to completely start all over again! It's a mess! 

Well, we have created an everyday solution to this mess, thanks to PAFWASA! PAFWASA is a personal assistant whose job is to assist its user in general weather advice and style tips the second he/she wakes up in the morning and opens his/her closet to start the day. 

PAFWASA lives in your closet (or a drawer if your wish). Assuming the closet light is turned on every day he/she enters for use, PAFWASA comes to life, which is simply an integrated circuit that incorporates processing for the user's benefit.

The way PAFWASA works is simple. It lives inside its own, aesthetically pleasing case. The Arduino is fairly simple as well, which includes a photoresistor circuit. Basically, the way we planned and implemented the circuit was so that once the light is turned on in the closet, it is intercepted by the photoresistor, who's data is then recorded, thus turning PAFWASA on. If no light is on, PAFWASA is off. 

After we built the circuit, we had to figure out the best way to write the code. We went through a few trial and error phases with the processing code, especially because the Yahoo Weather API, which we were using to access the live weather data, was extremely frustrating and difficult to implement at the beginning. Ultimately, we figured it out, and below you can see the code for processing and arduino.

We spent a long time toying around with the processing code to work out all the scenarios we have developped, how we would display the certain screens in processing, music visualizers, scroll through conditioning, and what would happen if we kept opening and closing the box based. We had to figure out a lot of different instances to make sure our PAFWASA worked the most efficiently! 