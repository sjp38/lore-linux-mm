Date: Mon, 25 Sep 2000 14:58:56 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925145856.A13011@athlon.random>
References: <20000925033128.A10381@athlon.random> <Pine.LNX.4.21.0009251207590.1459-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251207590.1459-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 12:13:08PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 12:13:08PM +0200, Ingo Molnar wrote:
> 
> On Mon, 25 Sep 2000, Andrea Arcangeli wrote:
> 
> > Not sure if this is the right moment for those changes though, I'm not
> > worried about ext2 but about the other non-netoworked fses that nobody
> > uses regularly.
> 
> it *is* the right moment to clean these issues up. These kinds of things

I'm talking about the removal of the superblock lock from the filesystems.

Note: I don't have problems with the removal of the superblock lock even if
done at this stage, I'm not the one who can choose those things, it's Linus's
responsability to take the final decision for the official tree, but don't ask
me to test patches that removes the superblock lock _at_this_stage_ before I
can run a stable and fast 2.4.x because I won't do that. Period.

> yet another elevator algorithm we need a squeaky clean VM balancer above

FYI: My current tree (based on 2.4.0-test8-pre5) delivers 16mbyte/sec in the
tiobench write test compared to clean 2.4.0-test8-pre5 that delivers 8mbyte/sec
instead with only blkdev layer changes in between the two kernels (and no
that's not a matter of the elevator since there are no seeks in the test
and I've not changed the elevator sorting algorithm during the bench).

Also I I found the reason of your hang, it's the TASK_EXCLUSIVE in
wait_for_request. The high part of the queue is reserved for reads.
Now if a read completes and it wakeups a write you'll hang.

If you think I should delay those fixes to do something else I don't agree
sorry. 

> all. Please help identifying, fixing, debugging and testing these VM
> balancing issues. This is tough work and it needs to be done.

I had an alternative VM, that I prefer from a design standpoint, I'll improve
it and I'll maintain it.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
