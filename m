Date: Sun, 28 Jul 2002 21:19:16 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] start_aggressive_readahead
In-Reply-To: <48F039DC-A282-11D6-A4C0-000393829FA4@cs.amherst.edu>
Message-ID: <Pine.LNX.4.44L.0207282117040.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: Andrew Morton <akpm@zip.com.au>, Christoph Hellwig <hch@lst.de>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 28 Jul 2002, Scott Kaplan wrote:

> > - We no longer put readahead pages on the active list.  They are placed
> >   on the head of the inactive list.  If nobody subsequently uses the
> >   page, it proceeds to the tail of the inactive list and is evicted.
>
> This seems a wise move, as placing them in the active list is only going
> to be beneficial in some very unusual cases.

I'm not sure about that. If we do linear IO we most likely
want to evict the pages we've already used as opposed to the
pages we're about to use.

This means that (1) we want to clear the accessed bit of the
pages we've already read, moving them to the inactive list if
needed  and (2) we'll want to keep the about-to-be-used pages
separate from the already-used pages.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
