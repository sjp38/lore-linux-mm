Date: Wed, 30 May 2001 19:51:03 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Plain 2.4.5 VM
In-Reply-To: <l03130306b73b215af2d5@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0105301939480.14444-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Rik van Riel <riel@conectiva.com.br>, Mark Hahn <hahn@coffee.psychology.mcmaster.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 30 May 2001, Jonathan Morton wrote:

> >The "getting rid of it" above consists of 2 parts:
> >
> >1) moving the page to the active list, where
> >   refill_inactive_scan will age it
> 
> Ummm...  I don't see any movement of pages to the "active" list in
> try_to_swap_out().

Hum? Increasing the page age will move it to the active list (indirectly,
of course) if it is already a swap cache page.

Otherwise the page will be added to the swapcache (which means it will be
added to the active list). 

> Instead, I see some very direct attempts to push the
> page onto backing store by some means.  In the stock kernel, this is done
> solely on the status of a single bit in the PTE, regardless of page->age or
> it's position on any particular list.

Allocating swap space for a page and adding the page to the swap cache
will not add it to the backing store immediately. 

> IOW, all the fannying around with page->age really has very little (if any)
> effect on the paging behaviour when it matters most - when memory pressure
> is so intense that kswapd is looping. 

Jonathan,

kswapd should never loop in the first place.

We have to limit aging.

With the current behaviour of the kernel, _all_ tasks are aging each
others pages when memory pressure is really high (apart from kswapd
possibly looping).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
