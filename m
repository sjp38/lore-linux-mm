Date: Fri, 13 Apr 2001 13:20:07 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
In-Reply-To: <m1wv8pti0o.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.21.0104131317110.12164-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Slats Grobnik <kannzas@excite.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

On 13 Apr 2001, Eric W. Biederman wrote:

> > Any suggestions for making Slats' ideas more generic so they work
> > on every system ?
> 
> Well I don't see how thrashing is necessarily connected to oom
> at all.  You could have Gigs of swap not even touched and still
> thrash.  

OOM leads to thrashing, however.

If we run out of memory and swap, all we can evict are the
filesystem-backed parts of memory, which includes mapped
executables.  This is how OOM and thrashing are connected.

What we'd like to see is have the OOM killer act before the
system thrashes ... if only because this thrashing could mean
we never actually reach OOM because everything grinds to a
halt.


Thrashing when we still have swap free is an entirely different
matter, which I want to solve with load control code. That is,
when the load gets too high, we temporarily suspend processes
to bring the load down to more acceptable levels.

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
