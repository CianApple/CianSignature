Signature

Signature View - Developed by Cian
 
 - Ready to use UIView for generating stylish signatures. Recently I found out that many apps needed an implementation of signatures. Till now we were using a primitive way to drawing signatures which not only looked ugly but also was not fast and memory consuming. So I started working on it and during my research I found out many different ways of achieving it. Mainly being Cocos2D, GLKit and Coregraphics. All are capable to implement this feature. 
 
 - But carefully analyzing our needs and to implement this feature in the easiest and best possible way. I found out that Coregraphics is the way to go. So I started researching and as we have worked on 'Racana', it didnt take much time to figure out a way to implement it. I sorted out the best possible memory efficient way which is very easy to implement in our projects.
 
 - Some of the better implementations are:
    * Using Gestures instead of UITouches.
    * Understanding a line smoothening alogrithm (Catmull-Spline algorithm) developed in language C.
    * This implementation was still laggy, so used drawingQueue and dispatch_async for curbing the lag.
    * Switch case provides some extra speed while jumping conditions
    * Catmull Rom Spline algorithm implemented for line smoothening
    * Ramer–Douglas–Peucker algorithm could also be used.
    * Adding buffer to improve the drawing experience.
    * Memory check when in ARC doesnt give a crash and is released properly.
    * Drawing a dot in coregraphics is easy but doesnt go with the flow. Tried to implement it properly but has no effect to match it with the line style.
 - There is still a large scope of improvement in this code. Practically we are using paid source codes like TenOne Autograph library for achieving this feature. It costs $99 for a single license and $499 for multiple licenses.
     So why to spend so much money if we can develop it ourselves.
 
 - Still things that are needed to be fixed:
    * Sometimes due to the velocity of finger touch, the line thickness becomes uneven.
    * For still better drawing performance, we can first draw the line real-time and then apply smoothening algorithm.
      This will significantly improve the performance but wouldn't give the feel of nice signature.
    * Implementing CALayer can boost the performance and memory.
    * Code for clearing the image is done but just need to add a code for capturing the signature as a UIImage (not that hard).
    * Make the class readily available for drag and drop use.
    * If you don't like ARC, just declare few variables globally and release them in dealloc.
    * You will notice that one end of the line is not pointed while the other end is. Code could be enhanced to do this which will make the signature look nice. I left it because it seemed to me like unnecessary calculations.
    * Implementing a dot/point is not impressive in our code. We can research a bit more on it and come out with a nice effect of it.
    
 Note: Have referred many sources on the internet so would not be able to list them out. But mainly try to search these keywords:
    * Catmull Rom Spline Algorithm
    * How to draw smooth lines in iOS
    * Azam Khan             (Best tutorial on this matter)
    * Ray Wanderlich        (Few tricks here)
    * Draw a point using uibezierpath
    * Make drawing in coregraphics faster
Hopefully we research more on this topic so that we can get more knowledge of coregraphics so that we can developer good memory efficient and eyecatchy apps for our business. Any more suggestions are welcome, we can try to improve it together. Please find the project in attachment.

Dankesun,
Jai Dhorajia
