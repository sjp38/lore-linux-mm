Date: Thu, 2 Aug 2007 14:26:21 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/4] vmemmap: pull out the vmemmap code into its own file
Message-ID: <20070802132621.GA9511@infradead.org>
References: <exportbomb.1186045945@pinky> <E1IGWw3-0002Xr-Dm@hellhawk.shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1IGWw3-0002Xr-Dm@hellhawk.shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 02, 2007 at 10:25:35AM +0100, Andy Whitcroft wrote:
> + * Special Kconfig settings:
> + *
> + * CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP
> + *
> + * 	The architecture has its own functions to populate the memory
> + * 	map and provides a vmemmap_populate function.
> + *
> + * CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP_PMD
> + *
> + * 	The architecture provides functions to populate the pmd level
> + * 	of the vmemmap mappings.  Allowing mappings using large pages
> + * 	where available.
> + *
> + * 	If neither are set then PAGE_SIZE mappings are generated which
> + * 	require one PTE/TLB per PAGE_SIZE chunk of the virtual memory map.
> + */

This is the kinda of mess I mean.  Which architecturs set either of these
and why?  This code would be a lot more acceptable if we hadn't three
different variants of the arch interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
