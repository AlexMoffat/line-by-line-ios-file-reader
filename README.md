# Line by Line File Reader

This is a complete example, see LineByLineFileReader.(h/m), of one way to read a file line by line in
iOS, something I couldn't find elsewhere. Reading is done asynchronously so that
any interface can remain responsive during the read. As lines are read from the file 
they are passed to a callback block. 
It uses the [NSStreamDelegate](http://developer.apple.com/library/mac/#documentation/cocoa/reference/NSStreamDelegate_Protocol/Reference/Reference.html)
protocol and the [NSStream](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSStream_Class/Reference/Reference.html) scheduleInRunLoop:forMode: method. The 
LineByLineFileReader stream:handleEvent: method is called repeatedly
from the [current run loop](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html).
Each time stream:handleEvent: is called it tries to read a buffer's worth of
data from the stream. This is converted into a string, appended to any existing 
data left over from the previous call to stream:handleEvent:, and split into lines.
These lines are passed one by one to the callback block. Any partial final line is
kept till the next time stream:handleEvent: is called again.

The provided project includes some unit tests for the LineByLineFileReader class.

## License

Licensed under the BSD 2-Clause License. See LICENSE.md for details.
