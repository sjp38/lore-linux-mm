Date: Mon, 4 Oct 1999 13:27:43 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: MMIO regions
In-Reply-To: <Pine.LNX.3.96.991004115631.500A-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.10.9910041308080.8295-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Oct 1999, Benjamin C.R. LaHaise wrote:

> On Mon, 4 Oct 1999, James Simmons wrote:
> 
> > And if the process holding the locks dies then no other process can access
> > this resource. Also if the program forgets to release the lock you end up
> > with other process never being able to access this piece of hardware.   
> 
> Eh?  That's simply not true -- it's easy enough to handle via a couple of
> different means: in the release fop or munmap which both get called on
> termination of a task.  

Which means only one application can ever have access to the MMIO. If
another process wanted it then this application would have to tell the
other appilcation hey I want it so unmap. Then the application demanding
it would then have to mmap it.  

> Or in userspace from the SIGCHLD to the parent, 

Thats assuming its always a child that has access to a MMIO region.

> or if you're really paranoid, you can save the pid in an owner field in
the
> lock and periodically check that the process is still there.
 
How would you use this method?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
