Date: Sun, 27 May 2001 14:51:30 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] modified memory_pressure calculation
In-Reply-To: <3B113CFB.B1ABAE0A@colorfullife.com>
Message-ID: <Pine.LNX.4.21.0105271451120.1907-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 May 2001, Manfred Spraul wrote:

> >          if (z->free_pages < z->pages_min / 4 &&
> > -           !(current->flags & PF_MEMALLOC))
> > +            (in_interrupt() || !(current->flags & PF_MEMALLOC)))
> >		continue;
> 
> It's 'if (in_interrupt()) continue', not 'if (in_interrupt()) alloc'.
> Currently a network card can allocate the last few pages if the
> interrupt occurs in the context of the PF_MEMALLOC thread. I think
> PF_MEMALLOC memory should never be available to interrupt handlers.

You're right, my mistake.

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
