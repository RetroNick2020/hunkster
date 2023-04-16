# hunkster
A Windows app that creates Amiga 68k hunk files to embed image/audio/data. 
Can be linked with Amiga vbcc and freepascal cross compilers.

In your C source code place the data name specified in hunkster as an extern statement. 
Note that in Hunkster the data name would be _dataname with an underscore. Other variations 
should work as well. You are just mapping a memory location to a variable/array. The contents 
of your variable/array will be what you imported in hunkster.

extern WORD dataname[];
extern LONG dataname_size;

vc yoursource.c hunkfile.o -o yourprogramname -lauto -lamiga

in freepascal code use {$L file.o}  //where file.o is the file you created in hunkster

procedure dataname; external '_dataname';

var
 dataname_size : long; external '_dataname_size';

![](https://github.com/retronick2020/hunkster/wiki/hunkstergui.png)
![](https://github.com/retronick2020/hunkster/wiki/hunkster_console.png)


