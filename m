Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA23552
	for <linux-mm@kvack.org>; Wed, 6 Jan 1999 18:33:42 -0500
Date: Thu, 7 Jan 1999 00:31:24 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.96.990106153725.714A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990107001448.1242B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>
Cc: bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jan 1999, Andrea Arcangeli wrote:

> I've put out arca-vm-9.

Woops in both arca-vm-8 and arca-vm-9 there was a very stupid bug in my
changes of the memory_trashing heuristic (done at too late time..). 
Basically when a process was masked to be a memory_trasher, it had no ways
to return a not marked process................ 

I didn' t noticed the bug because I use swap only when I do my benchmarks
(when there is not swapping in progress the slowdown due some
shrink_mmap() can't be seen with eyes...) and when I run my benchmarks I
always start before the memory trasher proggy...

Thanks to Benjamin who showed me the bugs some seconds ago ;)

I've put out a new arca-vm-10 with at least this bug fixed.

ftp://e-mind.com/pub/linux/kernel-patches/2.2.0-pre4-arca-VM-10

Excuse me...

BTW, I have reports that arca-vm-6/7 are faster than arca-vm-8/9
(arca-vm-7 is reported the fastest even more than arca-vm-3). Maybe it's
been due this bug that the latest are slower, or maybe the whole new
changes at the first memory_trashing code (the one in 2.2.0-pre4) are
hurting... (even if here them seems to helps, with them the trashing
process remains marked all the time and not only during low mem peak; and
not trashing process never get marked as trashing) 

And again thanks to Steve, Zlatko, Benjamin, Ben, Garst, MikeG, Kalle,
Brent and all other testers for their good reports! 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
