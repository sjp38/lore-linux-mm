Date: Sun, 21 May 2000 13:01:33 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: PATCH: Possible solution to VM problems (take 2)
In-Reply-To: <Pine.LNX.4.10.10005210112230.954-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0005211254240.9205-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 21 May 2000, Linus Torvalds wrote:

> The mm patchs in particular didn't apply any more, because my
> tree did some of the same stuff, so I did only a very very
> partial merge, much of it to just make a full merge later
> simpler. I made it available under testing as pre9-3, would you
> mind taking a look?

Looking good (well, I've only *read* the code, not
booted it).

The only change we may want to do is completely drop
the priority argument from swap_out since:
- if we fail through to swap_out we *must* unmap some pages
- swap_out isn't balanced against anything else, so failing
  it doesn't make much sense (IMHO)
- we really want do_try_to_free_pages to succeed every time

Of course I may have overlooked something ... please tell me
what :)

BTW, I'll soon go to work with some of davem's code and will
try to make a system with active/inactive lists. I believe the
fact that we don't have those now is responsible for the 
fragility of the current "balance" between the different memory
freeing functions... (but to be honest this too is mostly a
hunch)

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
