Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA10763
	for <linux-mm@kvack.org>; Mon, 4 Jan 1999 22:03:11 -0500
Subject: Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm improvement , [Re: 2.2.0 Bug summary]]
References: <Pine.LNX.3.96.990105012320.1107A-100000@laser.bogus>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 05 Jan 1999 04:02:00 +0100
In-Reply-To: Andrea Arcangeli's message of "Tue, 5 Jan 1999 01:32:17 +0100 (CET)"
Message-ID: <8790fiv2vr.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, steve@netplus.net, bredelin@ucsd.edu, sct@redhat.com, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@e-mind.com> writes:

> On Mon, 4 Jan 1999, Andrea Arcangeli wrote:
> 
> > I am going to do something like that right now...
> 
> Here a new patch (arca-vm-7). It pratically removes kswapd for all places
> except the ATOMIC memory allocation if there aren't process that are just
> freeing memory. 
> 

You have a bug somewhere!

At this point (output of Alt-SysRq-M), machine locked:

Jan  5 03:49:14 atlas kernel: Free pages:         512kB 
Jan  5 03:49:14 atlas kernel:  ( Free: 128 (128 256 384) 
Jan  5 03:49:14 atlas kernel: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 4*128kB = 512kB) 

Probably you have "< instead of <=", or similar logic problem
somewhere.

Bug revealed itself during "mmap-sync" run. It's a program that
utilises bug with shared mappings (you used to send patches for that
one, I don't know if they made it to the tree, so I check
occasionally).

Other than that, VM is really fast, in fact unbelievably fast. Kswapd
is very light on the CPU and interactive feel is great.
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
