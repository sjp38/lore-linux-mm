Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA15826
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 16:27:49 -0500
Date: Mon, 23 Nov 1998 22:25:58 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Linux-2.1.129..
In-Reply-To: <Pine.LNX.3.95.981123120028.5712B-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.981123221941.6004C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Nov 1998, Linus Torvalds wrote:
> On 23 Nov 1998, Eric W. Biederman wrote:
> > 
> > ST> That would be true if we didn't do the free_page_and_swap_cache trick.
> > ST> However, doing that would require two passes: once by the swapper, and
> > ST> once by shrink_mmap(): before actually freeing a page. 
> 
> This is something I considered doing. It has various advantages, and it's
> almost done already in a sense: the swap cache thing is what would act as
> the buffer between the two passes. 
> 
> Then the page table scanning would never really page anything out: it
> would just move things into the swap cache. That makes the table scanner
> simpler, actually. The real page-out would be when the swap-cache is
> flushed to disk and then freed.

For the buffer to properly act as an easy-freeable buffer
we will want to do the I/O based on the page table scanning
cycle, possibly with the addition of a special dirty list
we use for better I/O clustering.

> I'd like to see this, although I think it's way too late for 2.2

It is a bit late for implementing it wholesale, but this
system certainly looks like something we can implement
piece by piece, completing (well, sort of) the new VM
system at about 2.1.10...

Only having the dual pass freeing and some very basic
balancing can be implemented now, the more advanced
balancing (to gain more performance), a better dirty list,
swap block layout and other stuff can be implemented
gradually. It is a pretty modular system, from a coder's
point of view.

I am willing to maintain some sort of patch series
bringing the efforts from multiple people together
if you decide you really don't want it in 2.2 now.

regards,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
