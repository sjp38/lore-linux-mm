Date: Mon, 9 Sep 2002 23:02:14 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] modified segq for 2.5
In-Reply-To: <E17oaAt-0006x4-00@starship>
Message-ID: <Pine.LNX.4.44L.0209092301400.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Andrew Morton <akpm@digeo.com>, William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Sep 2002, Daniel Phillips wrote:

> > Skipping is dumb.  It shouldn't have been on that list in the
> > first place.
>
> Sure, it's not the only way to skin the cat.  Anyway, skipping isn't so
> dumb that we haven't been doing it for years.

Skipping might even be the correct thing to do, if we leave
the pages on the inactive list in strict LRU order instead
of wrapping them over to the other end of the list...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
