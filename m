Subject: Re: 2.5.44-mm2 compile error using gcc 3.2 (gcc 2.96 works fine).
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <3DB46C01.633299F9@digeo.com>
References: <1035225643.13078.86.camel@spc9.esa.lanl.gov>
	<3DB46C01.633299F9@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 21 Oct 2002 17:03:46 -0600
Message-Id: <1035241430.9472.24.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2002-10-21 at 15:05, Andrew Morton wrote:
> Steven Cole wrote:
> > 
> > I got the following error compiling 2.5.44-mm2 with gcc 3.2
> > as shipped with Mandrake 9.0 (3.2-1mdk).
> > 
> > kernel/softirq.c:353: cpu_nfb causes a section type conflict
> > make[1]: *** [kernel/softirq.o] Error 1
> > 
> > I was able to compile 2.5.44-mm2 with the same .config on another
> > machine using gcc 2.96 as shipped with RedHat 7.3 without this error.
> > Plain 2.5.44 built OK using gcc 3.2.
> > 
> > FWIW, I booted that 2.5.44-mm2 with CONFIG_SHAREPTE=y built with gcc
> > 2.96 and I have run KDE 3.0.3 without any problems so far.
> > 
> 
> Well gosh, you made me build gcc-3.2.  Couldn't resist benchmarking it:
> 
> time make -j3 bzImage ; size vmlinux:
> 
> gcc-3.2:
> 	781.26s user 62.84s system 185% cpu 7:34.41 total
>         text     data    bss    dec      hex    filename
> 	3395957  448896  419476 4264329  411189 vmlinux-3.2
> 
> 2.95.3:
> 	454.57s user 52.45s system 188% cpu 4:29.31 total
>         text     data    bss    dec      hex    filename
> 	3055661  445064  419476 3920201  3bd149 vmlinux-2.95.3
> 
> 2.91.66:
> 	420.78s user 51.87s system 188% cpu 4:11.09 total
>         text     data    bss    dec      hex    filename
> 	3125069  338536  526100 3989705  3ce0c9 vmlinux-2.91.66
> 
> Kinda makes you wonder why we're bothering, but ho hum.

Yeah, I know.  Ahh, for the days of 2.7.2.3.

> 
> I didn't see the error to which you refer.  What binutils
> are you using?
> 

binutils version is 2.12.90.0.15 for Mandrake 9.0.

BTW, I did a make mrproper on the gcc 3.2 box, retrieved the .config,
recompiled, and got the very same "section type conflict" error as
before.

After running the gcc 2.96 2.5.44-mm2 for a while longer, I started up
dbench and ran some an increasing client load up to 24 clients.  I
started a new Konsole in KDE and the system hung, not even responding to
pings. That failure was repeatable once, but after those two hangs which
required a hard reset, the system was able to run dbench 32 and launch
new Konsoles without hanging.  Non-deterministic behavior is so much
fun.

I'll do more testing tomorrow.

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
