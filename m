Date: Wed, 8 May 2002 04:13:49 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] rmap 13a
Message-ID: <20020508111349.GI15756@holomorphy.com>
References: <20020507183741.A25245@infradead.org> <Pine.LNX.4.33.0205080346450.31184-100000@dbear.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0205080346450.31184-100000@dbear.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Samuel Ortiz <sortiz@dbear.engr.sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2002 at 04:06:58AM -0700, Samuel Ortiz wrote:
> Some discontiguous architectures (ARM, for example) may be interested in
> getting rid of page->virtual, and thus shrinking the struct page size.
> So you may want to get the possibility of having
> (!CONFIG_HIGHMEM)&&CONFIG_DISCONTIGMEM and not wanting page->virtual.
> So, WANT_PAGE_VIRTUAL can not be defined with CONFIG_HIGHMEM ||
> CONFIG_DISCONTIGMEM.
> However, I should modify my patch in order for the changes to take place
> only if (!CONFIG_HIGHMEM)&&(CONFIG_DISCONTIG_MEM)&&(!WANT_PAGE_VIRTUAL).
> I can come back with the right changes if that makes sense to you.

Also, to be perfectly clear despite my message of perhaps extreme
conservatism regarding space conservation, I believe the time/space
tradeoff is an architectural consideration. Though I specifically
requested that a calculated UNMAP_NR_DENSE() be implemented, I by no
means oppose the usage of page->virtual for those architectures where
demonstrable performance benefits arise from the additional space
consumption of the extra field.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
