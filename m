Received: from ucla.edu (pool0009-max4.ucla-ca-us.dialup.earthlink.net [207.217.13.201])
	by serval.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id LAA13791
	for <linux-mm@kvack.org>; Sat, 16 Sep 2000 11:13:43 -0700 (PDT)
Message-ID: <39C3BA07.9525723F@ucla.edu>
Date: Sat, 16 Sep 2000 11:20:55 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: Happiness with t8-vmpatch4 (was Re:  Does page-aging really work?)
References: <Pine.LNX.4.21.0009160455260.1519-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> This is indeed something to look at. Maybe we could give
> idle processes (sleeping for more than 20 seconds?) a
> "full" swap_cnt instead of swap_cnt = rss >> SWAP_SHIFT ?
 
This doesn't seem like it should be necessary.  Right now, unused
processes ARE swapped preferentially (and completely) - its just that
swapping happens all of a sudden.

> And we could also start swapping a bit earlier when the
> cache is getting small, but I'm not sure about how to
> do this or exactly what performance benefits that would
> give ...

	Evicting unused pages, either from the cache or from process  can have
significant benefits on my machine (64Mb).  Once swapping triggered,
20Mb were paged out, and stayed out.  If these 20 Mb had been paged out
before, then I would have had 20Mb more cache to work with, which is 31%
of my memory.  Go figure :)
	While I agree with Byron that on low memory machines a smaller cache
can be a good thing - this DOES depend on the amount of RAM, and on the
workload.  But on higher memory machines, more aggressiveness against
program code is good.  Is there a way to make this adjust itself
dynamically - e.g. by measuring page faults?
	Anyway - I have seen the behavior that Byron described, where 'used'
increases as a result of a 'find'.  I think that maybe some more
aggressiveness against code pages (is that the right phrase?) might
solve the swapping problem and improve performance on low memory
machines also (since some code pages are simply evicted).

BTW, with test8-vmpatch4, I am gettings zillions of "VM: page_launder,
found pre-cleaned page ?!" messages.

-BenRI
-- 
"I want to be in the light, as He is in the Light,
 I want to shine like the stars in the heavens." - DC Talk, "In the
Light"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
