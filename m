Date: Wed, 17 Jan 2001 04:07:29 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Yet another bogus piece of do_try_to_free_pages()
In-Reply-To: <Pine.LNX.4.31.0101171755540.30841-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0101170407120.2909-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Zlatko Calusic <zlatko@iskon.hr>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 17 Jan 2001, Rik van Riel wrote:

> On 11 Jan 2001, Zlatko Calusic wrote:
> 
> > I have tested it for you and results are great. On some tests I got
> > 20% to 30% better results which is amazing. I'll do some more tests
> > but I would vote for this to get in immediately. Yes, it's *so* good.
> 
> Don't be so rash.
> 
> The patch hasn't been tested very thoroughly, otherwise
> people would have noticed the problem that PG_MEMALLOC
> isn't set around the page freeing code, possibly leading
> to deadlocks, triple faults and other nasties.

Look at 2.4.1pre8.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
