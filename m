Received: from MIT.EDU (SOUTH-STATION-ANNEX.MIT.EDU [18.72.1.2])
	by kvack.org (8.8.7/8.8.7) with SMTP id JAA28281
	for <linux-mm@kvack.org>; Thu, 27 May 1999 09:53:59 -0400
Message-Id: <199905271353.JAA09622@nerd-xing.mit.edu>
Subject: Re: dso loading question 
In-Reply-To: Your message of "Wed, 26 May 1999 21:44:41 PDT."
             <199905270444.VAA30288@google.engr.sgi.com>
Date: Thu, 27 May 1999 09:53:50 EDT
From: Kev <klmitch@MIT.EDU>
Sender: owner-linux-mm@kvack.org
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> [kanoj@entity /tmp]$ strace ./a.out
> execve("./a.out", ["./a.out"], [/* 18 vars */]) = 0
> brk(0)                                  = 0x8049558
> open("/etc/ld.so.preload", O_RDONLY)    = -1 ENOENT (No such file or directory)

lists dso's to link before any other dynamic linking occurs; useful for
overriding, say, malloc().

> open("/etc/ld.so.cache", O_RDONLY)      = 3

Contains a cache of where dso's are located on the disk, so the dynamic
linker doesn't have to search for them.

> I am trying to understand how dso loading works in Linux, specially at
> program startup time.

You might want to look at the source...
-- 
Kevin L. Mitchell <klmitch@mit.edu>
-------------------------  -. .---- --.. ..- -..-  --------------------------
http://web.mit.edu/klmitch/www/               (PGP keys availiable from here)
    RSA AE87D37D/1024:  DE EA 1E 99 3F 2B F9 23  A0 D8 05 E0 6F BA B9 D2
    DSS ED0DB34E/1024: D9BF 0E74 FDCB 43F5 C597  878F 9455 EC24 ED0D B34E
    DH  2A2C31D4/2048: 1A77 4BA5 9E32 14AE 87DA  9FEC 7106 FC62 2A2C 31D4

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
