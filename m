Date: Sun, 22 Apr 2001 15:57:32 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
In-Reply-To: <l03130312b708cf8a37bf@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0104221555090.1685-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: "James A. Sutherland" <jas88@cam.ac.uk>, "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 22 Apr 2001, Jonathan Morton wrote:

> I think we're approaching the problem from opposite viewpoints.  
> Don't get me wrong here - I think process suspension could be a
> valuable "feature" under extreme load, but I think that the
> working-set idea will perform better and more consistently under "mild
> overloads", which the current system handles extremely poorly.  

Could this mean that we might want _both_ ?

1) a minimal guaranteed working set for small processes, so root
   can login and large hogs don't penalize good guys
   (simpler than the working set idea, should work just as good)

2) load control through process suspension when the load gets
   too high to handle, this is also good to let the hogs (which
   would thrash with the working set idea) make some progress
   in turns

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
