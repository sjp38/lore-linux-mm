Date: Tue, 2 May 2000 12:43:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <390EFF9C.44C7CCE5@norran.net>
Message-ID: <Pine.LNX.4.21.0005021238430.10610-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 May 2000, Roger Larsson wrote:

> I have been playing with the idea to have a lru for each zone.
> It should be trivial to do since page contains a pointer to zone.
> 
> With this change you will shrink_mmap only check among relevant pages.
> (the caller will need to call shrink_mmap for other zone if call failed)

That's a very bad idea.

In this case you can end up constantly cycling through the pages of
one zone while the pages in another zone remain idle.

Local page replacement is worse than global page replacement and
has always been...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
