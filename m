Date: Thu, 18 Jan 2001 22:54:17 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <Pine.LNX.4.10.10101121617230.8097-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.31.0101182251520.3368-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jan 2001, Linus Torvalds wrote:

> If the page truly is new (because of some other user), then
> page_launder() won't drop it, and it doesn't matter. But
> dropping it from the VM means that the list handling can work
> right, and that the page will be aged (and thrown out) at the
> same rate as other pages.

Presuming the page isn't shared between multiple processes.

And even then, only the *down* aging will be at the same rate
as the other pages. The *up* aging will still be at the rate
we scan the virtual memory of the processes.

_This_ is one of the main reasons I want to try the reverse
page mappings ... the sheer fact that getting the balancing
right with the current scheme is hard, if not impossible.

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
