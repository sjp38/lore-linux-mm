Date: Wed, 14 Jun 2000 10:44:18 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006141453030.13222-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0006141039230.6334-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jun 2000, Andrea Arcangeli wrote:
> On Tue, 13 Jun 2000, Rik van Riel wrote:
> 
> >But when you switch around the order of allocation in your
> >hypothetical example, allocating the cache first, from the
> >ZONE_NORMAL and then proceeding to mlock the rest of the
> >normal zone and the dma zone, then classzone will still
> >break.
> 
> It doesn't break anything. You'll simply will not able to allocate memory
> with GFP_DMA anymore (that was happening seldom also in 2.2.x). If all the
> DMA zone is mlocked not being able to return GFP_DMA memory is normal.

So if the ZONE_DMA is filled by mlock()ed memory, classzone
will *not* try to balance it? Will classzone *only* try to
balance the big classzone containing zone_dma, and not the
dma zone itself?  (since the dma zone doesn't contain any
other zone, doesn't it need to be balanced?)

> If all the ZONE_NORMAL is mlocked but the ZONE_DMA is filled by cache
> having kswapd that loops forever wasting CPU in the ZONE_NORMAL is
> a broken behaviour IMHO.

A few mails back you wrote that the classzone patch would
do just about the same if a _classzone_ fills up. (except
that the different shrink_mmap() causes it to go to sleep
before being woken up again at the next allocation)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
