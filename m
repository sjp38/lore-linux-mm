Subject: 2.5.44-mm2 compile error using gcc 3.2 (gcc 2.96 works fine).
From: Steven Cole <elenstev@mesatop.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 21 Oct 2002 12:40:43 -0600
Message-Id: <1035225643.13078.86.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I got the following error compiling 2.5.44-mm2 with gcc 3.2
as shipped with Mandrake 9.0 (3.2-1mdk).

kernel/softirq.c:353: cpu_nfb causes a section type conflict
make[1]: *** [kernel/softirq.o] Error 1

I was able to compile 2.5.44-mm2 with the same .config on another
machine using gcc 2.96 as shipped with RedHat 7.3 without this error.
Plain 2.5.44 built OK using gcc 3.2.

FWIW, I booted that 2.5.44-mm2 with CONFIG_SHAREPTE=y built with gcc
2.96 and I have run KDE 3.0.3 without any problems so far.

Steven


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
