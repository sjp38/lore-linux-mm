Date: Mon, 17 Jul 2000 22:22:23 +0200 (CEST)
From: Mike Galbraith <mikeg@weiden.de>
Subject: Re: [PATCH] test5-1 vm fix
In-Reply-To: <Pine.LNX.4.10.10007171308190.13324-100000@coffee.psychology.mcmaster.ca>
Message-ID: <Pine.Linu.4.10.10007172115180.428-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jul 2000, Mark Hahn wrote:

> > RFC concerning make -j30 bzImage as basic VM test:
> > Rik called this an 'odd' workload.  IMHO it is an excellent basic VM test
> > (IFF the size of the job is adjusted to _not quite_ fit in ram).  In my
> 
> and do you know whether "make -j30" just barely exceeds ram?

On my box, yes.  It peaks higher than I like, though only briefly.

> > time make -j30 bzImage on 128mb PIII/500 w. single ide drive.
> 
> hmm I presume the disk is some reasonable mode (udma), but this 
> means that swapping will destructively interfere with any real IO.

Yes to both.  Swap is always destructive to other io unless you use
dedicated controllers/drives for swap.

My poor io system is exactly why I don't push hard.  I flat don't
have much bandwidth, and never want to reach max throughput.  When
I test VM, I'm generally looking to see how _little_ disk io is used.
This workload doesn't saturate disk when vm is working well.

(solid disk lite means you're trying to do the impossible.. I don't)

> I guess I don't see why this is a sane workload: it doesn't resemble
> basic workstation load (which never has 30 runnable processes),
> and it doesn't resemble "server" load (which might have 30, but would
> certainly have more than a single disk.)

I do this because it is cpu intensive with many jobs competing for
memory services.  I see it only as 30 cpu/memory hungry mouths to
feed, with the added benefit of having some (.h) cachable data to
see how well VM decides when/what to keep/toss.  It's certainly
overloaded.. the only time swap ever gets any real exercise.  My
only choice in testing is to do it with data or tasks.  It's easier
to use many tasks than just a couple with massive data and ensure
that io saturation isn't reached.

Sane?  My box could be a classroom box with thirty students with
an assignment to compile a program.. a kernel is a program ;-)

> > 31  7  0  18132  18856    768  18728   4   0   207     0  193   240  89  11   0
> > 30 10  0  18096   9680    792  19164 132   0   324     0  191   422  92   8   0
> > 37  3  0  15556   6968    788  12092 424   0   325    19  165   353  88  12   0
> > 27  3  1  18940  23724    640  12624 11008 8948  9705  3006 5284  7710  63  10  28
> 
> hmm, clearly going over 30 several times.  and in this case, the forkbomb
> is causing the machine to thrash.  unsurprising eh?

It goes over thirty, but is not forkbombing the box.  Old make, you had
to be very very careful with.. new make throttles itself pretty well.

	Thanks for your comments.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
