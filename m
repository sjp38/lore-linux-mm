Date: Wed, 13 Nov 2002 17:37:15 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] 10/4  -ac to newer rmap
In-Reply-To: <20021113193348.A29582@infradead.org>
Message-ID: <Pine.LNX.4.44L.0211131735380.3817-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Nov 2002, Christoph Hellwig wrote:

> >  /*
> >   * Wait for a page to get unlocked.
> >   *
> >   * This must be called with the caller "holding" the page,
> >   * ie with increased "page->count" so that the page won't
> >   * go away during the wait..

	[snip last 2 paragraphs of comment]

> >   */
>
> What is the pint of removing comments?

These comments really were excessively large.  The main point of
this particular patch would be to bring -rmap and -ac in line so
it's easier to merge patches from one kernel into the other.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://guru.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
