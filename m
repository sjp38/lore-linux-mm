Date: Mon, 15 May 2000 12:27:56 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] VM stable again?
In-Reply-To: <Pine.LNX.4.10.10005151729430.6248-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0005151227010.20410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 May 2000, Ingo Molnar wrote:
> On Mon, 15 May 2000, Rik van Riel wrote:
> 
> > - keep track of whether some process is critically low on
> >   memory and needs to call try_to_free_pages()
> > - if another allocation starts while the other app is in
> >   try_to_free_pages(), free some memory ourselves
> > - (skip point 2 if there is enough free memory, but that's
> >   just a minor performance optimisation)
> 
> yep, this should work. A minor comment:
> 
> > +		if (atomic_read(&free_before_allocate))
> 
> i believe this needs to be per-zone and should preferably be
> read within the zone spinlock - not atomic operations. Updating
> a global counter is a big time problem on SMP.

It should be per-pgdat. Per-zone probably won't work since
having this counter per-zone may interfere with both fallback
and balancing between the zones.

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
