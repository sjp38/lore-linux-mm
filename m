Date: Mon, 4 Oct 1999 14:26:31 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: MMIO regions
In-Reply-To: <Pine.LNX.3.96.991004134519.1698A-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.10.9910041409120.8295-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Which means only one application can ever have access to the MMIO. If
> > another process wanted it then this application would have to tell the
> > other appilcation hey I want it so unmap. Then the application demanding
> > it would then have to mmap it.  
> 
> GUG!  Think: you've got a file descriptor, if you implement an ioctl to
> lock it, then your release op gets called when the app dies.  But
> Stephen's suggestion of using the SYSV semaphores for the user code is
> better. 

Okay that can be fixed. What about if the process goes to sleep? Most
important thing I was trying to get at was both processes both wanting to
use the MMIO region at the same time. Okay if we expand on the idea of
semaphore what we are doing is really recreating shared memory of IPC.
Note IPC sharded memory does not handle similatneous access to the memory.
Usually a userland semaphore is used. Now a rogue app can access this
memory if they have the key and ignore the semaphore. Of course this is
only ram and this would only fubar the apps using this memory. What I'm
talking about is messing up the hardware and locking the machine.

> > How would you use this method?
> 
> man 2 kill.

Userland has to explictly kill it or have the other process send a
kill signal for within the kernel. All I want to do is suspend the
processes that might access the MMIO region while one is using it. Of
course I could use signals in the kernel to do that.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
