Date: Sat, 25 Aug 2001 00:20:59 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][PATCH] __alloc_pages_limit & order > 0
In-Reply-To: <200108242253.f7OMrbQ20401@mailf.telia.com>
Message-ID: <Pine.LNX.4.33L.0108250017130.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.33L.0108250017132.5646@imladris.rielhome.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Aug 2001, Roger Larsson wrote:

> To begin with if order > 0 then direct_reclaim will be false even if
> it is allowed to wait...

That's because direct_reclaim can only reclaim 1 page from
the page cache at the same time, while a higher-order alloc
needs _multiple_ pages.

Thus, by definition, a direct-reclaim won't satisfy a higher
order allocation.

> This version allows direct_reclaim with order > 0 !

The old code already did this, albeit in a very ugly way.

I'd like to see the old code cleaned up, but I'm not too happy
about the main loop being complicated because of these (very rare)
higher-order allocations.

IIRC somebody measured his system one day and 99.5% of the allocs
were 0-order GFP_USER or GFP_KERNEL, so I guess we really want to
keep the multi-order allocs from messing with the main allocation
loop.

Then again, please do clean up the multi-order allocation page
cleaning loop, the way I coded it originally is just plain ugly ;)

regards,

Rik -- after a few drinks, so apply a grain of salt ;)
-- 
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
