Date: Wed, 17 Jan 2001 18:27:10 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Aggressive swapout with 2.4.1pre4+ 
In-Reply-To: <Pine.LNX.4.21.0101160138140.1556-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.31.0101171825340.30841-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jan 2001, Marcelo Tosatti wrote:

> Currently swap_out() scans a fixed percentage of each process RSS without
> taking into account how much memory we are out of.
>
> The following patch changes that by making swap_out() stop when it
> successfully moved the "needed" (calculated by refill_inactive()) amount
> of pages to the swap cache.
>
> This should avoid the system to swap out to aggressively.
>
> Comments?

The big problem doesn't seem to be this. The big problem
seems to be that we don't do IO in page_launder() smooth
enough.

All the above patch does is make _allocation_ of swap and
clearing of page table entries smoother, but those are not
the actions that have a performance impact.

(and yes, I tested all these things while I was sitting in
my hotel room for 5 days without any net access)

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
