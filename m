Date: Sat, 14 Jul 2007 10:49:31 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 0/7] Sparsemem Virtual Memmap V5
Message-ID: <20070714084931.GE1198@wotan.suse.de>
References: <617E1C2C70743745A92448908E030B2A01EA6524@scsmsx411.amr.corp.intel.com> <Pine.LNX.4.64.0707131510350.25753@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707131510350.25753@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 13, 2007 at 03:21:43PM -0700, Christoph Lameter wrote:
> On Fri, 13 Jul 2007, Luck, Tony wrote:
> 
> > 1) There is a small performance regression for ia64 (which is promised
> > to go away when bigger pages are used for the mem_map, but I'd like to
> > see that this really does fix the issue).
> 
> The performance should be better than the existing one since we have even 
> less code here than discontig. We do no have to fetch the base anymore or 
> check boundaries (discontig was the baseline right?) but we have exactly 
> the same method of pfn_to_page and page_to_pfn as discontig/vmemmap.

Isn't it still possible that you could have TLB pressure that would
result in lower performance? I wonder why the large page support for
ia64 was shelved?

FWIW, since I was cc'ed for comments: I really like the patches as well
although much of it is in memory model and arch code which I'm not so
involved with.

It should allow better performance, and unification of most if not all
memory models which will be really nice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
