Date: Fri, 18 May 2001 23:18:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: on load control / process swapping
In-Reply-To: <l03130302b72ad6e553b5@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0105182315430.5531-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Matt Dillon <dillon@earth.backplane.com>, Terry Lambert <tlambert2@mindspring.com>, Charles Randall <crandall@matchlogic.com>, Roger Larsson <roger.larsson@norran.net>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2001, Jonathan Morton wrote:

> FWIW, I've been running with a 2-line hack in my kernel for some weeks
> now, which essentially forces the RSS of each process not to be forced
> below some arbitrary "fair share" of the physical memory available.  
> It's not a very clean hack, but it improves performance by a very
> large margin under a thrashing load.  The only problem I'm seeing is a
> deadlock when I run out of VM completely, but I think that's a
> separate issue that others are already working on.

I'm pretty sure I know what you're running into.

Say you guarantee a minimum of 3% of memory for each process;
now when you have 30 processes running your memory is full and
you cannot reclaim any pages when one of the processes runs
into a page fault.

The minimum RSS guarantee is a really nice thing to prevent the
proverbial root shell from thrashing, but it really only works
if you drop such processes every once in a while and swap them
out completely. You especially need to do this when you're
getting tight on memory and you have idle processes sitting around
using their minimum RSS worth of RAM ;)

It'd work great together with load control though. I guess I should
post a patch for - simple&naive - load control code once I've got
the inodes and the dirty page writeout code balancing fixed.

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
