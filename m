Date: Sun, 22 Apr 2001 16:11:36 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
In-Reply-To: <o7a6ets1pf548v51tu6d357ng1o0iu77ub@4ax.com>
Message-ID: <Pine.LNX.4.21.0104221610190.1685-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A.Sutherland" <jas88@cam.ac.uk>
Cc: Jonathan Morton <chromi@cyberspace.org>, "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 22 Apr 2001, James A.Sutherland wrote:

> >But login was suspended because of a page fault,
> 
> No, login was NOT *suspended*. It's sleeping on I/O, not suspended.
> 
> > so potentially it will
> >*also* get suspended for just as long as the hogs.  
> 
> No, it will get CPU time a small fraction of a second later, once the
> I/O completes.

You're assuming login won't have the rest of its memory (which
it needs to do certain things) swapped out again in the time
it waits for this page to be swapped in...

... which is exactly what happens when the system is thrashing.

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
