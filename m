Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA11845
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 09:22:37 -0500
Date: Tue, 26 Jan 1999 15:21:58 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m1059TX-0007U1C@the-village.bc.nu>
Message-ID: <Pine.LNX.4.03.9901261513280.26867-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, groudier@club-internet.fr, torvalds@transmeta.com, werner@suse.de, andrea@e-mind.com, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 1999, Alan Cox wrote:

> Chop memory into 4Mb sized chunks that hold the perfectly normal
> and existing pages and buddy memory allocator. Set a flag on
> 25-33% of them to a max of say 10 and for <12Mb boxes simply say
> "tough".

We might also want to flag non-cached and dma areas too.
That way we can hand cached, non-dma memory to the kernel,
use non-cached stuff for buffer memory and page tables,
keeping dma-able memory relatively clean and keeping the
kernel (and critical pages) fast.

Maybe the execute bit should also have some influence on
placement. Having executable text in uncached memory may
well give a larger performance penalty than putting user
data there...

In my zone allocator design I have outlined 5 or 7 (depending
on how you look at it) different memory usages for the Linux
kernel. You might want to check that out to see if you've
overlooked something:

http://www.nl.linux.org/~riel/zone-alloc.html

> The performance impact of that on free page requests seems to be
> pretty minimal. In actual fact it wil help performance in some
> cases since the machine can't easily be killed by going out of non
> kernel space allocations - the 25% is also a "can do work" sanity
> check.

It's very well possible to keep separate free memory stats
and free memory from the different area's as needed.

cheers,

Rik -- If a Microsoft product fails, who do you sue?
+-------------------------------------------------------------------+
| Linux memory management tour guide.             riel@nl.linux.org |
| Scouting Vries cubscout leader.     http://www.nl.linux.org/~riel |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
