Date: Sat, 25 Sep 1999 21:19:59 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909251905110.4120-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9909252050590.25425-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Sat, 25 Sep 1999, James Simmons wrote:
> 
> >Is their any way to do cooperative locking kernel side between two memory
> >regions? If one is being access you can't physically access the other. I
> >just want to process to sleep not kill it if it attempts this.
> 
> Ah ok.

To be exactly I'm trying to do cooperative locking between a mmaping of
the accel region of /dev/gfx and the framebuffer region of /dev/fb. I
notice that after mmapping the kernel can no long control access to the
memory regions. So I need to block any process from accessing the
framebuffer while the accel engine is running. Since many low end cards
lock if you access the framebuffer and accel engine at the same time. 
Note /dev/fb and /dev/gfx both can be opened by different processes.

> So just add a spinlock in userspace. As test_and_set_bit works in
> userspace also the spinlock will work fine in userspace.

Really. Thats a good idea.

> Just make sure to always have the lock held before touching the memory
> region you want to serialize the accesses to.
> 
> You need to add the locking into userspace.

Will this work for mmap regions as well?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
