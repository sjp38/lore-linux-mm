Date: Wed, 17 Sep 2003 16:33:08 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: How best to bypass the page cache from within a kernel module?
In-Reply-To: <20030917195044.GH14079@holomorphy.com>
Message-ID: <Pine.LNX.4.44L0.0309171617560.1646-100000@ida.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 2003-09-17 at 11:24, Alan Stern wrote:
> > However, all that seems rather roundabout.  An equally acceptable solution 
> > would be simply to invalidate all the entries in the page cache referring 
> > to my file, so that reads would be forced to go to the drive.  Can anyone 
> > tell me how to do that?

On Wed, Sep 17, 2003 at 12:44:29PM -0700, Dave Hansen wrote:
> Whatever you're trying to do, you probably shouldn't be doing it in the
> kernel to begin with.  Do it from userspace, it will save you a lot of
> pain.

That's not particularly helpful, especially considering that the entire
driver currently works just fine as a kernel module, with the exception of
this one piece.  (This one piece works too; it just doesn't do exactly 
what I want.)

On Wed, 17 Sep 2003, William Lee Irwin III wrote:
> If you really want to bypass the pagecache etc. entirely, use raw io and
> don't even bother mounting the filesystem, and do it all from userspace.
> If you need it simultaneously mounted then you're in somewhat deeper
> trouble, though you can probably be rescued by nefarious means like that
> bit about shooting down the pagecache so you don't have some incoherent
> cache headache.

I really want this to work through the filesystem.  99% of what my driver 
does involves normal reads and writes.  And there are very good reasons 
for having it run as a kernel thread rather than a user process.  It's 
just that this one piece, which is a very minor part of the driver, needs 
to avoid the page cache.

So to reiterate my original questions:

1. What's the proper way for a kernel thread running in a module to get
hold of an mm_struct or to keep the one it had before calling daemonize()?

2. What's the proper way for a kernel thread to allocate a region of 
userspace memory?

3. What's the proper way to invalidate all entries in the page cache that 
refer to a particular file?

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
