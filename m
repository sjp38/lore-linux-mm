Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA11286
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 08:33:14 -0500
Message-Id: <m1059TX-0007U1C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Tue, 26 Jan 1999 14:28:19 +0000 (GMT)
In-Reply-To: <199901261306.NAA16382@dax.scot.redhat.com> from "Stephen C. Tweedie" at Jan 26, 99 01:06:41 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: groudier@club-internet.fr, alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It is really not hard to reserve a certain amount of memory (up to some
> fraction, say 25% or 50% of physical memory) for use only by pagable

I was guessing 25%. 

> allocations.  Most desktop boxes will _not_ require more than 50% of
> memory for locked kernel pages.  Recovering any given range of
> contiguous pages from that pagable region may be expensive but will
> _always_ be possible, and given that it will usually be a one-off
> expense during driver setup, there is no reason why we cannot support
> it.

Something like

Chop memory into 4Mb sized chunks that hold the perfectly normal and existing
pages and buddy memory allocator. Set a flag on 25-33% of them to a max of say 
10 and for <12Mb boxes simply say "tough". 

The performance impact of that on free page requests seems to be pretty minimal.
In actual fact it wil help performance in some cases since the machine can't 
easily be killed by going out of non kernel space allocations - the 25% is
also a "can do work" sanity check.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
