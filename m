Date: Wed, 17 Jan 2001 17:58:39 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Yet another bogus piece of do_try_to_free_pages()
In-Reply-To: <87r92bq75w.fsf@atlas.iskon.hr>
Message-ID: <Pine.LNX.4.31.0101171755540.30841-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11 Jan 2001, Zlatko Calusic wrote:

> I have tested it for you and results are great. On some tests I got
> 20% to 30% better results which is amazing. I'll do some more tests
> but I would vote for this to get in immediately. Yes, it's *so* good.

Don't be so rash.

The patch hasn't been tested very thoroughly, otherwise
people would have noticed the problem that PG_MEMALLOC
isn't set around the page freeing code, possibly leading
to deadlocks, triple faults and other nasties.

(and yes, I'm sure there will be somebody able to trigger
this bug)

Remember that we - officially - still are in the 2.4 BUGFIX
period, it's time to be careful with the code now and we should
IMHO not randomly introduce new bugs in the name of performance.

Performance enhancements are perfectly fine, of course, but IMHO
not after they've been posted 2 hours ago and haven't been
reviewed and stresstested yet.

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
