Date: Mon, 8 Jan 2001 14:42:38 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.21.0101081101430.5599-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0101081440320.21675-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jan 2001, Marcelo Tosatti wrote:
> On Sun, 7 Jan 2001, Linus Torvalds wrote:
> 
> > and just get rid of all the logic to try to "find the best mm". It's bogus
> > anyway: we should get perfectly fair access patterns by just doing
> > everything in round-robin, and each "swap_out_mm(mm)" would just try to
> > walk some fixed percentage of the RSS size (say, something like
> > 
> > 	count = (mm->rss >> 4)
> > 
> > and be done with it.
> 
> I have the impression that a fixed percentage of the RSS will be
> a problem when you have a memory hog (or hogs) running.

My RSS ulimit enforcing patches solve this problem in a
very simple way.

If a process is exceeding its RSS limit, we scan ALL pages
from the process. Otherwise, we scan the normal percentage.

Furthermore, I have put a default soft RSS limit of half
of physical memory in the system. This means that when you
have one big runaway process, kswapd will be more agressive
against that process then against others. The fact that it
is a soft limit, OTOH, means that the process can use all
the available memory if there is no memory pressure in the
system...

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
