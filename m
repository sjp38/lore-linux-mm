Date: Sun, 26 Sep 1999 16:07:17 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909252050590.25425-100000@imperial.edgeglobal.com>
Message-ID: <Pine.LNX.4.10.9909261602340.439-100000@laser.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Sep 1999, James Simmons wrote:

>framebuffer while the accel engine is running. Since many low end cards
>lock if you access the framebuffer and accel engine at the same time. 

I see your point.

>Note /dev/fb and /dev/gfx both can be opened by different processes.

If they are two threads and so if they are sharing the same process MM,
you can simply alloc the spinlock in the .data segment (trivial global
variable).

If the two process are not threads (so if they are not sharing the same
MM) then alloc the spinlock (or in general the memory you want to use as
an atomic lock) in a shared shm segment.

>Will this work for mmap regions as well?

Sure: you only need to always acquire the spinlock before accessing the
region of virtual memory. It doesn't metter which kind of memory you are
going to access.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
