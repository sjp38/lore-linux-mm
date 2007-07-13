Date: Fri, 13 Jul 2007 15:21:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: [PATCH 0/7] Sparsemem Virtual Memmap V5
In-Reply-To: <617E1C2C70743745A92448908E030B2A01EA6524@scsmsx411.amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0707131510350.25753@schroedinger.engr.sgi.com>
References: <617E1C2C70743745A92448908E030B2A01EA6524@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007, Luck, Tony wrote:

> 1) There is a small performance regression for ia64 (which is promised
> to go away when bigger pages are used for the mem_map, but I'd like to
> see that this really does fix the issue).

The performance should be better than the existing one since we have even 
less code here than discontig. We do no have to fetch the base anymore or 
check boundaries (discontig was the baseline right?) but we have exactly 
the same method of pfn_to_page and page_to_pfn as discontig/vmemmap.

These types of variation may come about due to the concurrency in memory 
detection / reservations in the PROM on Altix systems which results in 
variances in the placement of key memory areas. Performance often varies 
slightly because of these issues.

If performance testing done on an Altix then the solution is to redo 
the tests a couple of time, each time rebooting the box. Or redo it again 
on a SMP box that does not have these variations.

How many tests were done and on what platform?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
