Date: Tue, 17 Mar 1998 00:36:41 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: PATCH: rev_pte_1 -- please test
In-Reply-To: <199803162259.WAA02995@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.95.980317000927.17338A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Stephen,

On Mon, 16 Mar 1998, Stephen C. Tweedie wrote:

> Hi Ben,
> 
> A first quick comment on the new vma stuff:
> 
> Hmm, you've overloaded the vma/vm_offset stuff with the inode queues!
> That's OK in principle --- the swap cache stuff currently maintains both
> the per-inode page lists AND the hash lists, but only the hash lists are
> strictly necessary so I guess we can live with that.  

That's my thinking - the inode queues are so infrequently used that it
makes very little difference in complexity, plus if a page is on an inode
queue it can't be anonymous.

> There's also the guts of a page queue implementation --- have you got
> any firmer plans for that?  I'm still uncertain about the benefits of
> having these queues, except for the obvious use of the dumpable list.

I'm not sure what effect they'll have, but I'd like to try them at least
(this could be put off until later).  My suspicions are that it will make
a difference where we might have to make several passes before a page
reaches a low enough age to be thrown out.  This is a huge problem on a
386 I have - it has a swap partition on a local IDE drive with root
mounted over nfs.  When memory consumption is high, kswapd eats most cpu
time, yet still isn't able to free up enough pages to keep the system
humming along.  The same thing could happen on the other end of the
RAM size/CPU speed ratio - when aging becomes nescessary it can eat up a
lot of cpu time before it produces any results -> not good.

I was away over the weekend, so no new code... Perhaps by the end of the
week mmscan.c might be useful, and merge_vm_segments will get patched &
tested. (the mlock code seems to work - I forgot that xntpd uses mlock) 

		-ben
