Date: Sat, 24 Feb 2001 09:51:23 -0500 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: VM balancing problems under 2.4.2-ac1
In-Reply-To: <3A976CE1.C7493E89@ucla.edu>
Message-ID: <Pine.LNX.4.31.0102240949020.8568-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 24 Feb 2001, Benjamin Redelings I wrote:
> Rik van Riel wrote:
> > In 2.4.1-pre<something> the kernel swaps out cache 32 times more
> > agressively than it scans pages in processes. Until we find a way
> > to auto-balance these things, expect them to be wrong for at least
> > some workloads ;(
>
> and elsewhere,
>
> > That's because your problem requires a change to the
> > balancing between swap_out() and refill_inactive_scan()
> > in refill_inactive()...
>
> Rik, can you explain why we still need to "balance" things,
> instead of just swapping out the least used pages?  Is this only
> a problem with the 2.4 implementation (e.g. will
> refill_inactive_scan eventually do swap_out in 2.5, or
> something?), or is it a generic VM issue that has to be solved?

The problem is that we scan processes by _virtual address_
and the cache by physical page. Furthermore, there are LOTS
of pages which are present in both the cache AND in processes.

Say, for example, that on a 64MB system you have 32MB cache but
half of that cache is cached executable text and swap cache (which
is also mapped into processes).

Now how would you adjust the scanning rate of processes and cache
to make sure we age each page in the system at approximately the
same rate ?

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
