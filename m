Date: Wed, 8 May 2002 04:06:58 -0700 (PDT)
From: Samuel Ortiz <sortiz@dbear.engr.sgi.com>
Subject: Re: [PATCH] rmap 13a
In-Reply-To: <20020507183741.A25245@infradead.org>
Message-ID: <Pine.LNX.4.33.0205080346450.31184-100000@dbear.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 May 2002, Christoph Hellwig wrote:

> On Mon, May 06, 2002 at 11:17:26PM -0300, Rik van Riel wrote:
> > rmap 13a:
> >   - NUMA changes for page_address                         (Samuel Ortiz)
>
> I don't think the changes makes sense.  If calculating page_address is
> complicated and slow enough to place it out-of-lin using page->virtual
> is much better.
This is right for machines who don't care about the struct page size, like
SGI ones, and big NUMA machines in general.


> I'd suggest backing this patch out and instead always maintain page->virtual
> for discontigmem.  While at this as a little cleanup you might want to
> define WANT_PAGE_VIRTUAL based on CONFIG_HIGHMEM || CONFIG_DISCONTIGMEM
> at the top of mm.h instead of cluttering it up.
Some discontiguous architectures (ARM, for example) may be interested in
getting rid of page->virtual, and thus shrinking the struct page size.
So you may want to get the possibility of having
(!CONFIG_HIGHMEM)&&CONFIG_DISCONTIGMEM and not wanting page->virtual.
So, WANT_PAGE_VIRTUAL can not be defined with CONFIG_HIGHMEM ||
CONFIG_DISCONTIGMEM.
However, I should modify my patch in order for the changes to take place
only if (!CONFIG_HIGHMEM)&&(CONFIG_DISCONTIG_MEM)&&(!WANT_PAGE_VIRTUAL).
I can come back with the right changes if that makes sense to you.

Cheers,
Samuel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
