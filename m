Date: Thu, 19 Jul 2007 16:25:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/7] x86_64: SPARSEMEM_VMEMMAP 2M page size support
Message-Id: <20070719162529.66302406.akpm@linux-foundation.org>
In-Reply-To: <E1I9LK3-00007i-2T@hellhawk.shadowen.org>
References: <exportbomb.1184333503@pinky>
	<E1I9LK3-00007i-2T@hellhawk.shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007 14:36:39 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

> x86_64 uses 2M page table entries to map its 1-1 kernel space.
> We also implement the virtual memmap using 2M page table entries.  So
> there is no additional runtime overhead over FLATMEM, initialisation
> is slightly more complex.  As FLATMEM still references memory to
> obtain the mem_map pointer and SPARSEMEM_VMEMMAP uses a compile
> time constant, SPARSEMEM_VMEMMAP should be superior.
> 
> With this SPARSEMEM becomes the most efficient way of handling
> virt_to_page, pfn_to_page and friends for UP, SMP and NUMA on x86_64.
> 
> [apw@shadowen.org: code resplit, style fixups]
> From: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> ---
> diff --git a/Documentation/x86_64/mm.txt b/Documentation/x86_64/mm.txt

Please put the From: attribution right at the top of the changelog.

Please alter your scripts to include diffstat output after the ^---

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
