Date: Wed, 17 Jan 2001 18:05:25 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <Pine.LNX.4.21.0101122038420.10842-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.31.0101171804160.30841-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jan 2001, Marcelo Tosatti wrote:
> On Fri, 12 Jan 2001, Linus Torvalds wrote:
>
> > If the page truly is new (because of some other user), then page_launder()
> > won't drop it, and it doesn't matter. But dropping it from the VM means
> > that the list handling can work right, and that the page will be aged (and
> > thrown out) at the same rate as other pages.
>
> What about the amount of faults this potentially causes?

The change has 2 influences on the number of faults:

1. the number of soft faults should probably increase

2. refill_inactive_scan() can deactivate more pages, since
   less pages will be trapped inside processes ... this can
   lead to better page replacement and less hard page faults

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
