Date: Wed, 26 Apr 2000 19:49:59 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.10.10004260949400.1492-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0004261917100.1687-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: riel@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Apr 2000, Linus Torvalds wrote:

>On Wed, 26 Apr 2000, Andrea Arcangeli wrote:
>> 
>> NUMA is irrelevant. If there's no inclusion the classzone matches with the
>> zone.
>
>But then all your arguments evaporate.
>
>If you argue that memory balancing should work even in the instance where
>the classzone has degenerated into a single zone, [..]

Yes, I argue this otherwise my alpha box would not run stable anymore ;).

>[..] then I'll just say "why
>have the classzone concept at all, then?".

Because it's necessary to handle correctly the other case: setups where we
have to handle overlapped zones.

Note that the ZONE_DMA is classzone composed by one single zone too and of
course memory balancing have to work correctly with ZONE_DMA too.

>I think we should have zones. Not classzones. And we should have
>"zonelists", but those would not be first-class data structures, they'd
>just be lists of zones that are acceptable for an allocation.

My only problem is that I don't see how to solve the subtle drawbacks
elecated in my previous emails by keeping the strict zone based approch
and without considering the other zone_t that compose the real zone
(classzone) that we want to allocate from.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
