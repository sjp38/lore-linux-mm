Date: Mon, 17 Jul 2000 13:21:00 -0400 (EDT)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: [PATCH] test5-1 vm fix
In-Reply-To: <Pine.Linu.4.10.10007160808001.420-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.10.10007171308190.13324-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@weiden.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> RFC concerning make -j30 bzImage as basic VM test:
> Rik called this an 'odd' workload.  IMHO it is an excellent basic VM test
> (IFF the size of the job is adjusted to _not quite_ fit in ram).  In my

and do you know whether "make -j30" just barely exceeds ram?

> time make -j30 bzImage on 128mb PIII/500 w. single ide drive.

hmm I presume the disk is some reasonable mode (udma), but this 
means that swapping will destructively interfere with any real IO.
I guess I don't see why this is a sane workload: it doesn't resemble
basic workstation load (which never has 30 runnable processes),
and it doesn't resemble "server" load (which might have 30, but would
certainly have more than a single disk.)


> 31  7  0  18132  18856    768  18728   4   0   207     0  193   240  89  11   0
> 30 10  0  18096   9680    792  19164 132   0   324     0  191   422  92   8   0
> 37  3  0  15556   6968    788  12092 424   0   325    19  165   353  88  12   0
> 27  3  1  18940  23724    640  12624 11008 8948  9705  3006 5284  7710  63  10  28

hmm, clearly going over 30 several times.  and in this case, the forkbomb
is causing the machine to thrash.  unsurprising eh?

peak was 41, I think.  I presume this is because make isn't counting 
the multiple processes that gcc -pipe forks.

regards, mark hahn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
