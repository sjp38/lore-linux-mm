Date: Sat, 9 Sep 2000 01:58:04 +0200 (CEST)
From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: test8-vmpatch performs great here!
In-Reply-To: <20000908192042.A31685@tentacle.dhs.org>
Message-ID: <Pine.LNX.4.21.0009090149210.1839-100000@tux.rsn.hk-r.se>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: deprogrammer <ttb@tentacle.dhs.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Sep 2000, deprogrammer wrote:

> 
> After reading ben's email I dicided to run his same test on my box
> running test8 + vmpatch3 
> 
> some specs: K7 - 600, 128MB ram.
> 
> environment: X 4.0.1 and netscape 4.75 were running.
> 
> I ran 2 tests:
> 	1) tar zxvf linux-2.4.0-test6.tar.gz
> 	2) tar xvf linux-2.4.0-test6.tar
> 
> 
> free_before:
> 	total       used       free     shared    buffers     cached
> 	Mem:        127176      62960      64216          0       2164      25500
> 	-/+ buffers/cache:      35296      91880
> 	Swap:       128516          0     128516
> 
> free_after_tgz:
> 	total       used       free     shared    buffers     cached
> 	Mem:        127176     124892       2284          0       6612      80592
> 	-/+ buffers/cache:      37688      89488
> 	Swap:       128516          0     128516
> 
> free_after_tar:
> total       used       free     shared    buffers     cached
> Mem:        127176     124952       2224          0       2848      85336
> -/+ buffers/cache:      36768      90408
> Swap:       128516          0     128516
> 
> The box remained somewhat interactive, but a few times during the tar zxvf the
> box would stop responding for a few seconds during which there would be alot
> of disk activity, same for the tar xvf.

I have to say that the vm-patch against t8p5 works fine here on t8p6

I've tested to copy a few big files between partitions and it didn't swap
at all (it used to swap like crazy leaving me to watch my frozen X during
the copy)

so far so good....

then a friend started a ftp-session against my machine and started to copy
a few files (3-6MB each via 100Mbit network) and my machine began swapping
like there was no tomorrow.

after about 15-30 seconds of heavy swapping the swapping stopped, now I
had about 35MB swapped out (I have 256MB ram, and the box is very light
loaded, no big memoryhogs or anything (not even netscape :))

I took a look at /proc/meminfo and I had more than 200MB in active pages
and almost nothing in inactive pages. So this is a case where drop-behind
doesn't work yet.

I should say that my ftpserver is proftpd-1.2.0pre10, a quite common
ftpserver

/Martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
