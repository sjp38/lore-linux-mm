Date: Fri, 14 Jan 2000 02:08:49 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <Pine.LNX.4.10.10001131650520.2250-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10001140205540.13454-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@chiara.csoma.elte.hu>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2000, Linus Torvalds wrote:
> On Fri, 14 Jan 2000, Andrea Arcangeli wrote:
> > 
> > The only problem in what you are suggesting is that you may end swapping
> > out also the wrong pages. Suppose you want to allocate 4k of DMA
> > memory.
> 
> I agree.
> 
> HOWEVER, I don't think this is going to be a huge issue in most cases. And
> if people don't need non-DMA memory, then the pages we "swapped" out are
> going to stay in RAM anyway, so it's not going to hurt us.

If the page is not dirtied after we swapped it out last time,
it won't matter one bit for performance. If the page is dirtied
continuously we won't swap out that page either.

All the swap-everything, free later thing means is that we'll
incur a little extra I/O (in the background) and that it might
be easier/faster to free pages in the foreground, when we really
need them.

> Anyway, I obviously do agree that I may well be wrong, and that
> real life is going to come back and bite us, and we'll end up
> having to not do it this way. However, I'd prefer trying the
> "conceptually simple" path first, and only if it turns out that
> yes, I was completely wrong, do we try to fix it up with magic
> heuristics etc.

I don't think there will be that many side effects, except
perhaps a bit higher swap usage...

Of course, under certain workloads the two different tactics
will make a difference, but that can swing either way.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
