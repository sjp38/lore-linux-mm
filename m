Received: from chelm.cs.nmt.edu (yodaiken@chelm.cs.nmt.edu [129.138.6.50])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA24112
	for <linux-mm@kvack.org>; Wed, 27 Jan 1999 05:45:09 -0500
From: yodaiken@chelm.cs.nmt.edu
Message-Id: <199901271031.DAA02948@chelm.cs.nmt.edu>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Wed, 27 Jan 1999 03:31:17 -0700 (MST)
In-Reply-To: <Pine.LNX.3.96.990126161041.11981C-100000@chiara.csoma.elte.hu> from "MOLNAR Ingo" at Jan 26, 99 04:21:30 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: mingo@chiara.csoma.elte.hu
Cc: alan@lxorguk.ukuu.org.uk, sct@redhat.com, groudier@club-internet.fr, torvalds@transmeta.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> i dont think it's correct to say: 'anything that cannot be segmented in
> the physical memory space with page granularity, is considered to be
> broken in this regard and is not guaranteed to be 100% supported by the
> Linux architecture'. 

Sure. But let's keep in mind that paging is designed to avoid memory
fragmentation, and big chunks mean you don't care about some minor loss
of usable memory. If you have a 4G phys memory and need big linear pieces,
it is far better to waste 3.9 meg by aligning end of data, then to complicate
all memory allocation techniques in kernel so you don't waste it. In fact
you'd probably want a simplified slab
         kmalloc:
               if size is 4meg allocate a 4meg chunk from 4meg list
               else if size< 4 meg
                    either allocate a new 4 meg chunk and take space from it
                    or find partially used 4 meg chunk with enough space in it.

so you might have a list of partially used 4meg chunks lying about wasting
some space, but ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
