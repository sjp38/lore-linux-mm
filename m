Date: Thu, 21 Dec 2000 17:42:24 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Interesting item came up while working on FreeBSD's pageout
 daemon
In-Reply-To: <3A423423.F73F1225@innominate.de>
Message-ID: <Pine.LNX.4.21.0012211741410.1613-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@innominate.de>
Cc: Matthew Dillon <dillon@apollo.backplane.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Dec 2000, Daniel Phillips wrote:
> Matthew Dillon wrote:
> >     My conclusion from this is that I was wrong before when I thought that
> >     clean and dirty pages should be treated the same, and I was also wrong
> >     trying to give clean pages 'ultimate' priority over dirty pages, but I
> >     think I may be right giving dirty pages two go-arounds in the queue
> >     before flushing.  Limiting the number of dirty page flushes allowed per
> >     pass also works but has unwanted side effects.
> 
> Hi, I'm a newcomer to the mm world, but it looks like fun, so I'm
> jumping in. :-)
> 
> It looks like what you really want are separate lru lists for
> clean and dirty.  That way you can tune the rate at which dirty
> vs clean pages are moved from active to inactive.

Let me clear up one thing. The whole clean/dirty story
Matthew wrote down only goes for the *inactive* pages,
not for the active ones...

regards,

Rik
--
Hollywood goes for world dumbination,
	Trailer at 11.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
