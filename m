Date: Thu, 13 Jan 2000 19:37:18 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <E128ntG-0007sV-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.10.10001131936040.13454-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, andrea@suse.de, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2000, Alan Cox wrote:

> > I think that busier machines probably have a larger need
> > for DMA memory than this code fragment will give us. I
> > have the gut feeling that we'll want to keep about 512kB
> > or more free in the lower 16MB of busy machines...
> 
> 2.2.x uses a simple algorithm. Normally allocations come from the
> main pool if it fails we use the DMA pool. That seems to work just
> fine.

Of course, I should have thought of that.

Our `high-to-low' allocation strategy should make
sure that the free pages `propagate down'...

Now we'll only want to build something into kswapd
so that rebalancing the high memory zones is done in
the background.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
