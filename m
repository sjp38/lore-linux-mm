Date: Wed, 15 Aug 2001 19:34:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 0-order allocation problem 
In-Reply-To: <Pine.LNX.4.33.0108151528180.887-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33L.0108151933340.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2001, Linus Torvalds wrote:
> On Wed, 15 Aug 2001, Marcelo Tosatti wrote:
> >
> >  __GFP_IO is not going to help us that much on anon intensive workloads
> > (eg swapoff). Remember we are _never_ going to block on buffer_head's of
> > on flight swap pages because we can't see them in page_launder(). (if a
> > page is locked, we simply skip it)
>
> Note that that is what we have the page_alloc (and buffer head)
> reserves for - and it doesn't take that much to get the ball rolling.
> Certainly not even close to our low-water-marks.. And once it
> snowballs it _does_ help that people call page_launder().

Also, page_launder() tends to "strip" the buffer heads
from pages as soon as they get cleaned, making them
immediately available to the process trying to allocate
a buffer head and calling page_launder() from buffer.c

regards,

Rik
--
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
