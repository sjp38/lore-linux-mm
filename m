Date: Tue, 2 May 2000 18:42:31 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <20000502221405.O1389@redhat.com>
Message-ID: <Pine.LNX.4.21.0005021837080.10610-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Roger Larsson <roger.larsson@norran.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 May 2000, Stephen C. Tweedie wrote:
> On Tue, May 02, 2000 at 02:06:20PM -0300, Rik van Riel wrote:
> > > do the smart things I was mentining some day ago in linux-mm
> > > with NUMA.
> > 
> > How do you want to take care of global page balancing with
> > this "optimisation"?
> 
> You don't.  With NUMA, the memory is inherently unbalanced, and you
> don't want the allocator to smooth over the different nodes.

Ermmm, a few days ago (yesterday?) you told me on irc that we
needed to balance between zones ... maybe we need some way to
measure "memory load" on a zone and only allocate from a different
NUMA zone if:

	local_load        remote_load
	----------   >=   -----------
	1.0               load penalty for local->remote

(or something more or less like this ... only use one of the
nodes one hop away if the remote load is <90% of the local
load, 70% for two hops, 30% for > 2 hops ...)

We could use the scavenge list in combination with more or
less balanced page reclamation to determine memory load on
the different nodes...

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
