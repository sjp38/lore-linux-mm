Date: Tue, 2 May 2000 14:06:20 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <Pine.LNX.4.21.0005021818070.1919-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0005021405030.10610-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Roger Larsson <roger.larsson@norran.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 May 2000, Andrea Arcangeli wrote:
> On Tue, 2 May 2000, Rik van Riel wrote:
> 
> >That's a very bad idea.
> 
> However the lru_cache have definitely to be per-node and not
> global as now in 2.3.99-pre6 and pre7-1 or you won't be able to
> do the smart things I was mentining some day ago in linux-mm
> with NUMA.

How do you want to take care of global page balancing with
this "optimisation"?

If you cannot find a good answer to that, you'd better not
spend too much time implementing any of this...

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
