Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA20498
	for <linux-mm@kvack.org>; Mon, 21 Oct 2002 14:05:06 -0700 (PDT)
Message-ID: <3DB46C01.633299F9@digeo.com>
Date: Mon, 21 Oct 2002 14:05:05 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.44-mm2 compile error using gcc 3.2 (gcc 2.96 works fine).
References: <1035225643.13078.86.camel@spc9.esa.lanl.gov>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Steven Cole wrote:
> 
> I got the following error compiling 2.5.44-mm2 with gcc 3.2
> as shipped with Mandrake 9.0 (3.2-1mdk).
> 
> kernel/softirq.c:353: cpu_nfb causes a section type conflict
> make[1]: *** [kernel/softirq.o] Error 1
> 
> I was able to compile 2.5.44-mm2 with the same .config on another
> machine using gcc 2.96 as shipped with RedHat 7.3 without this error.
> Plain 2.5.44 built OK using gcc 3.2.
> 
> FWIW, I booted that 2.5.44-mm2 with CONFIG_SHAREPTE=y built with gcc
> 2.96 and I have run KDE 3.0.3 without any problems so far.
> 

Well gosh, you made me build gcc-3.2.  Couldn't resist benchmarking it:

time make -j3 bzImage ; size vmlinux:

gcc-3.2:
	781.26s user 62.84s system 185% cpu 7:34.41 total
        text     data    bss    dec      hex    filename
	3395957  448896  419476 4264329  411189 vmlinux-3.2

2.95.3:
	454.57s user 52.45s system 188% cpu 4:29.31 total
        text     data    bss    dec      hex    filename
	3055661  445064  419476 3920201  3bd149 vmlinux-2.95.3

2.91.66:
	420.78s user 51.87s system 188% cpu 4:11.09 total
        text     data    bss    dec      hex    filename
	3125069  338536  526100 3989705  3ce0c9 vmlinux-2.91.66

Kinda makes you wonder why we're bothering, but ho hum.

I didn't see the error to which you refer.  What binutils
are you using?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
