Date: Mon, 27 Sep 1999 16:22:19 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: mm->mmap_sem
In-Reply-To: <14319.31833.53685.244682@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9909271616080.7835-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hi,
> 
> On Sat, 25 Sep 1999 21:19:59 -0400 (EDT), James Simmons
> <jsimmons@edgeglobal.com> said:
> 
> > To be exactly I'm trying to do cooperative locking between a mmaping of
> > the accel region of /dev/gfx and the framebuffer region of /dev/fb. 
> 
> I thought you might be.  Look at the DRI (XI's direct rendering
> infrastructure): they implement a cooperative locking mechanism which
> optimises the fast case (current locker was also the last holder of the
> lock) not to require a syscall at all.

Already am peeking under the hood.

> Using any form of physical memory protection will be too slow.

Agree. 

> > I notice that after mmapping the kernel can no long control access to
> > the memory regions. So I need to block any process from accessing the
> > framebuffer while the accel engine is running. Since many low end
> > cards lock if you access the framebuffer and accel engine at the same
> > time.
> 
> I know.  The hardware sucks.  There is no fast way to deal with it.  The
> closest you might get to it is ia32 segmentation, but we don't support
> that in the kernel and never will.

Well if the number of cards that are broken this bad are small then I will
just not support such cards. If simulatenous access just screws up the
screen well that will not count. As long as crumy hardware is not allowed
to lock the machine.

> You still don't prevent a rogue application from locking the graphics
> adapter. 

Yuck. I rather not support that kind of hardware if that type of hardware 
is small in numbers. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
