Date: Tue, 13 Jun 2000 23:46:13 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006140351010.12294-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0006132341190.3455-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jun 2000, Andrea Arcangeli wrote:
> On Tue, 13 Jun 2000, Rik van Riel wrote:
> >On Wed, 14 Jun 2000, Andrea Arcangeli wrote:
> >
> >> >and we can support all corner cases of usage well without it. In
> >> >fact, as I demonstrated above, even your own contorted example will
> >> >hang classzone if I only switch the order in which the allocations
> >> >happen...
> >> 
> >> It won't hang, but kswapd will eat CPU and that's right in your case. The
> >> difference that you can't see is that in the second scenario where the
> >> classzone would spend CPU in kswapd the CPU is spent for a purpose that
> >> have a sense. In the first scenario where classzone wouldn't any spend
> >> CPU, the CPU in kswapd would infact be _wasted_.
> >
> >Now explain to me *why* this happens. I'm pretty sure this happens
> >because of the 'dispose = &old' in shrink_mmap and not because of
> >anything even remotely classzone related...
> 
> You waste CPU in kswapd in the first scenario simply because you
> are not looking backwards at the ZONE_DMA state at the time you
> have to choose if you did some progress on the ZONE_NORMAL zone.
>
> The problem isn't related to shrink_mmap, but only to the zone design
> (proper classzone part).

But when you switch around the order of allocation in your
hypothetical example, allocating the cache first, from the
ZONE_NORMAL and then proceeding to mlock the rest of the
normal zone and the dma zone, then classzone will still
break.

> >I'm trying to improve the Linux kernel here, I'd appreciate it if
> >you were honest with me.
> 
> Are you saying I'm not been honest with you? JFYI: I don't enjoy to get
> insulted by you (and it's not the first time). I will ignore also your
> above comment but please don't insult me anymore in the future! Thanks.

Conveniently snipping out the part of my post where I proved
your example wrong is not what I'd call constructive dialog.
Maybe the "honesty" thing was a bit much. I should get some
sleep and try again tomorrow using less inflammatory words.

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
