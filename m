Date: Sat, 25 Sep 1999 12:50:57 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909251639140.1083-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9909251232540.22660-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Sep 1999, Andrea Arcangeli wrote:

> On Fri, 24 Sep 1999, James Simmons wrote:
> 
> >Just out of curoisty how would one revoke all read-write to that page?
> 
> man mprotect (have a look to PROT_NONE)
> 
> >I know this would be expensive to do.
> 
> If you don't know how to do that how do you know it's expensive? ;)

Well I kind of figured I would have to do what mprotects does. I just
needed someone to say yes mprotect is the way to not allow processes
physical access to a memory region. I just wanted to make sure I was
right. Also I don't want the process to be sent a SIGSEGV. I just want to
put it to sleep for a period of time if it access such a region.

> But indeed you are right: it's a bit expensive as if the pages are just
> allocated you'll have to change all their ptes.

Like mprotect does. How does this compare to unmmaping a large memory
region and putting a process to sleep in a no_page_fault routine.

Is their any way to do cooperative locking kernel side between two memory
regions? If one is being access you can't physically access the other. I
just want to process to sleep not kill it if it attempts this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
