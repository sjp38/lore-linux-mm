Date: Sat, 9 Jun 2001 00:48:45 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.31.0106081706260.10744-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0106090047320.10415-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, "David S. Miller" <davem@redhat.com>, Mike Galbraith <mikeg@wen-online.de>, Zlatko Calusic <zlatko.calusic@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2001, Linus Torvalds wrote:

> But it would be interesting to hear what people think of moving the
> swap_out() call into refill_inactive_scan() instead of doing it
> outside.. However, that would further confuse the meaning of the
> "target" and "maxscan" in the scanning phase.

This would work if we had all the anonymous pages on the
active list, so we have an idea when we have had to "skip"
too many pages due to being mapped.

Doing things this way would also give us the information
we need to do some actual VM balancing...

regards,

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
