Date: Tue, 7 May 2002 11:03:28 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] rmap 13a
Message-ID: <20020507180328.GS15756@holomorphy.com>
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com> <20020507183741.A25245@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020507183741.A25245@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2002 at 11:17:26PM -0300, Rik van Riel wrote:
>> rmap 13a:
>>   - NUMA changes for page_address                         (Samuel Ortiz)

On Tue, May 07, 2002 at 06:37:41PM +0100, Christoph Hellwig wrote:
> I don't think the changes makes sense.  If calculating page_address is
> complicated and slow enough to place it out-of-lin using page->virtual
> is much better.

On Tue, May 07, 2002 at 06:37:41PM +0100, Christoph Hellwig wrote:
> I'd suggest backing this patch out and instead always maintain page->virtual
> for discontigmem.  While at this as a little cleanup you might want to
> define WANT_PAGE_VIRTUAL based on CONFIG_HIGHMEM || CONFIG_DISCONTIGMEM
> at the top of mm.h instead of cluttering it up.
> 	Christoph

This is a time/space tradeoff that may not necessarily be the case for
all discontiguous memory architectures. It seems to be so for SGI's
machines, though. I advocated this as a matter of generality, despite
not having a specific example of a machine that wants it. It's not
difficult to produce examples of small-memory architectures with
discontiguous memory, though SGI's discontigmem implementation does
not appear to be in widespread use for them.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
