Date: Fri, 24 Sep 1999 21:24:40 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: mm->mmap_sem
In-Reply-To: <14315.48702.873172.788668@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9909242002500.16745-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> Yes.  The semaphore only protects against changes to the mmap lists and
> page tables.  It does not protect memory itself.  On a multi-processor
> machine, the only way the kernel on one CPU can prevent the contents of
> a page from being modified by a process on another CPU is to forcibly
> revoke all read-write mappings to that page.

Just out of curoisty how would one revoke all read-write to that page?
I know this would be expensive to do.

Also what does LockPage, TryLockPage(page), and UnlockPage(page) do
exactly? I assume this also doesn't protect the memory contents either.
What I'm guessing at is it protects the page struct itself. If you are
changing the protections on a page you don't want a another process also
attempting to do this. 

> currently in the process's page tables.  If the page is already mapped,
> then there is no page fault.  Otherwise you'd be doing massive amounts
> of kernel work for every byte of data accessed by every process.

Makes sense. I see its a clock algorithm that looks threw the pages and
markes the pages as dirty that have been accessed. Thanks to the link
below I see how thats done. 

Cooperative locking between the framebuffer and accel engine is going to
be alot harder than I though. I was hoping the mmap_sem might do the
trick. I was hoping to find a nice clean way to have it so when the accel
engine is about to become active any access to the framebuffer could just
be reschedule for later execution. You stated that something similar to
sharded memory would work. I toke alook at the code. It looks like all it
does is add a extra layer above ordinary memory handling. How would I
approach this problem with the shared memory method ?

> --Stephen
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
