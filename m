Date: Wed, 17 Jan 2001 20:22:48 +0100 (CET)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: <mingo@elte.hu>
Subject: Re: Yet another bogus piece of do_try_to_free_pages()
In-Reply-To: <87snmirodw.fsf@atlas.iskon.hr>
Message-ID: <Pine.LNX.4.30.0101172021270.7218-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: Rik van Riel <riel@conectiva.com.br>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 17 Jan 2001, Zlatko Calusic wrote:

> Oh, believe me I tested that patch very thoroughly with lots of
> utilities, and it worked very very well. I don't remember that it
> fiddled anywhere with the PG_MEMALLOC flag.

yep, same result here, Marcelo's patch is plain *wonderful*. Combined with
the block-IO changes, -pre8 is really behaving spectacularly in under high
VM or pagecache load.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
