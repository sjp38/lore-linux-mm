Date: Sat, 14 Jul 2007 08:07:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/7] Sparsemem Virtual Memmap V5
In-Reply-To: <20070714084931.GE1198@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0707140803300.30485@schroedinger.engr.sgi.com>
References: <617E1C2C70743745A92448908E030B2A01EA6524@scsmsx411.amr.corp.intel.com>
 <Pine.LNX.4.64.0707131510350.25753@schroedinger.engr.sgi.com>
 <20070714084931.GE1198@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Sat, 14 Jul 2007, Nick Piggin wrote:

> Isn't it still possible that you could have TLB pressure that would
> result in lower performance? I wonder why the large page support for
> ia64 was shelved?

16M Large memmap support was shelved because 16M is too large a size for 
a vmemmap block. It results in the vmemmap overlapping multiple nodes.

The TLB pressure for the 16k support is the same since its the same 
algorithm. We are measuring discontig/vmemmap 16k against sparse/vmemmap 
16k here.

We would likely see a different if we would compare sparsemem vs. 
sparse/vmemmap. Then there may be a difference in TLB pressure. But 16k 
discontig/vmemmap is the current default on IA64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
