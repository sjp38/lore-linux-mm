Date: Mon, 29 Jul 2002 05:04:23 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] start_aggressive_readahead
In-Reply-To: <3D44F01A.C7AAA1B4@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207290503150.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Scott Kaplan <sfkaplan@cs.amherst.edu>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jul 2002, Andrew Morton wrote:

> >  Similarly, you would want to be very
> > cautious about increasing the size of the read-ahead window of many pages
> > at the end of the inactive list are being re-used.
>
> I tend to think that if pages at the tail of the LRU are being
> referenced with any frequency we've goofed anyway.  There are
> many things apart from readahead which will allocate pages, yes?

It would be a useful thing to measure, though.

We can use this information to decide to:

1) reduce readahead and, if if the situation continues

2) do load control

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
