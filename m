Date: Sun, 13 May 2001 14:22:21 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: on load control / process swapping
In-Reply-To: <200105122358.f4CNwEr20137@earth.backplane.com>
Message-ID: <Pine.LNX.4.21.0105131417550.5468-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: arch@freebsd.org, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On Sat, 12 May 2001, Matt Dillon wrote:

> :But if the larger processes never get a chance to make decent
> :progress without thrashing, won't your system be slowed down
> :forever by these (thrashing) large processes?
> :
> :It's nice to protect your small processes from the large ones,
> :but if the large processes don't get to run to completion the
> :system will never get out of thrashing...
> 
>     Consider the case where you have one large process and many small
>     processes.  If you were to skew things to allow the large process to
>     run at the cost of all the small processes, you have just inconvenienced
>     98% of your users so one ozob can run a big job.

So we should not allow just one single large job to take all
of memory, but we should allow some small jobs in memory too.

>     What if there are several big jobs?  If you skew things in favor of
>     one the others could take 60 seconds *just* to recover their RSS when
>     they are finally allowed to run.  So much for timesharing... you
>     would have to run each job exclusively for 5-10 minutes at a time
>     to get any sort of effiency, which is not practical in a timeshare
>     system.  So there is really very little that you can do.

If you don't do this very slow swapping, NONE of the big tasks
will have the opportunity to make decent progress and the system
will never get out of thrashing.

If we simply make the "swap time slices" for larger processes
larger than for smaller processes we:

1) have a better chance of the large jobs getting any work done
2) won't have the large jobs artificially increase memory load,
   because all time will be spent removing each other's RSS
3) can have more small jobs in memory at once, due to 2)
4) can be better for interactive performance due to 3)
5) have a better chance of getting out of the overload situation
   sooner

I realise this would make the scheduling algorithm slightly
more complex and I'm not convinced doing this would be worth
it myself, but we may want to do some brainstorming over this ;)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
