From: "ZCane, Ed (Test Purposes)" <zed.cane@roke.co.uk>
Message-ID: <005701c32e68$de7b12b0$d8c176c1@roke.co.uk>
Subject: Word of advice, please.
Date: Mon, 9 Jun 2003 10:24:04 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello all,

I appreciate this is probably trivial to you experts, but would be very
grateful if you could spare a minute to tell me if I'm on the right tracks,
or barking up the wrong tree!

I'm trying to write a system to capture large amounts of data from a Gb
Ethernet card. Using Linux, Kernel Version 2.4.

I've done a bit of reading, and this is how I propose to do it.

Allocate a large block (500mb) of contiguous physical memory, at boot time,
using bootmem.
Share this memory with user-space processess, using memmap and shared memory
IPC.
Modify our Ethernet driver so that it DMA's into my block of memory.

I'll use semaphores, and split the memory into separate chunks, and make it
so it rotates in a ring buffer style, I can handle all that stuff, just
wanted to make sure I was on the right tracks with the design/concept of the
memory.

Any advice appreciated, dont wish to take too much of your time!

Best regards,
Ed




begin 666 RMRL-Disclaimer.txt
M4F5G:7-T97)E9"!/9F9I8V4Z(%)O:V4@36%N;W(@4F5S96%R8V@@3'1D+"!3
M:65M96YS($AO=7-E+"!/;&1B=7)Y+"!"<F%C:VYE;&PL( T*0F5R:W-H:7)E
M+B!21S$R(#A&6@T*#0I4:&4@:6YF;W)M871I;VX@8V]N=&%I;F5D(&EN('1H
M:7,@92UM86EL(&%N9"!A;GD@871T86-H;65N=',@:7,@8V]N9FED96YT:6%L
M('1O(%)O:V4@#0T-"DUA;F]R(%)E<V5A<F-H($QT9"!A;F0@;75S="!N;W0@
M8F4@<&%S<V5D('1O(&%N>2!T:&ER9"!P87)T>2!W:71H;W5T('!E<FUI<W-I
M;VXN(%1H:7,@#0T-"F-O;6UU;FEC871I;VX@:7,@9F]R(&EN9F]R;6%T:6]N
M(&]N;'D@86YD('-H86QL(&YO="!C<F5A=&4@;W(@8VAA;F=E(&%N>2!C;VYT
;<F%C='5A;" -#0T*<F5L871I;VYS:&EP+@T*
end

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
