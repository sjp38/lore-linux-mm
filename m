Date: Tue, 7 May 2002 18:37:41 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] rmap 13a
Message-ID: <20020507183741.A25245@infradead.org>
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com>; from riel@conectiva.com.br on Mon, May 06, 2002 at 11:17:26PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2002 at 11:17:26PM -0300, Rik van Riel wrote:
> rmap 13a:
>   - NUMA changes for page_address                         (Samuel Ortiz)

I don't think the changes makes sense.  If calculating page_address is
complicated and slow enough to place it out-of-lin using page->virtual
is much better.

I'd suggest backing this patch out and instead always maintain page->virtual
for discontigmem.  While at this as a little cleanup you might want to
define WANT_PAGE_VIRTUAL based on CONFIG_HIGHMEM || CONFIG_DISCONTIGMEM
at the top of mm.h instead of cluttering it up.

	Christoph

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
