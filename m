From: "ZCane, Ed (Test Purposes)" <zed.cane@roke.co.uk>
Message-ID: <01d901c32f46$aa240790$d8c176c1@roke.co.uk>
References: <Pine.LNX.4.51.0306101052160.14891@dns.toxicfilms.tv> <46580000.1055180345@flay> <Pine.LNX.4.51.0306092017390.25458@dns.toxicfilms.tv> <51250000.1055184690@flay> <Pine.LNX.4.51.0306092140450.32624@dns.toxicfilms.tv> <20030609200411.GA26348@holomorphy.com> <Pine.LNX.4.51.0306101052160.14891@dns.toxicfilms.tv> <5.2.0.9.2.20030610125606.00cd04a0@pop.gmx.net> <20030610114123.GP15692@holomorphy.com>
Subject: Sharing Boottime allocated memory with user-space processes
Date: Tue, 10 Jun 2003 12:51:44 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dear All,

Just a quick pointer in the right direction required, again!

I'm allocating a large buffer at boot-time, from the kernel, using
alloc_bootmem_low_pages, which
I wish to use for DMA from an device driver.

For example, the bootmem returns an address of 0xc0006000. This all works
fine, but...

What is the mechanism for communicating this address to user-space
processes, and mapping it to a virtual address, so that they can use my
buffer?

Sorry for asking something undoubtedly trivial!

Cheers,

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
