Date: Sat, 21 Apr 2001 17:29:42 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
In-Reply-To: <3AE1DCA8.A6EF6802@earthlink.net>
Message-ID: <Pine.LNX.4.21.0104211724380.1685-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Joseph A. Knapka" <jknapka@earthlink.net>
Cc: "James A. Sutherland" <jas88@cam.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 21 Apr 2001, Joseph A. Knapka wrote:
> "James A. Sutherland" wrote:
> > 
> > Note that process suspension already happens, but with too fine a
> > granularity (the scheduler) - that's what causes the problem. If one
> > process were able to run uninterrupted for, say, a second, it would
> > get useful work done, then you could switch to another. The current
> > scheduling doesn't give enough time for that under thrashing
> > conditions.
> 
> This suggests that a very simple approach might be to just increase
> the scheduling granularity as the machine begins to thrash. IOW,
> use the existing scheduler as the "suspension scheduler".

That doesn't work.  The CPU scheduler works on very small time
scales and won't run any process anyway when all of them are
waiting for IO.

What we want instead is a 2nd level scheduler which simply uses
the standard mechanisms of the kernel to temporarily suspend a
few processes on a LONGER timescale (multiple seconds) and makes
sure the normal scheduler doesn't even try to run them when all
the non-suspended processes are waiting for disk.

Btw, I have something like this almost working ...

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
