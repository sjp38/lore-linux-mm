Message-ID: <45BD5E8D.6080206@yahoo.com.au>
Date: Mon, 29 Jan 2007 13:40:13 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC 0/8] Use ZVCs for accurate writeback ratio determination
References: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com> <45B9F26D.5090107@yahoo.com.au> <Pine.LNX.4.64.0701260745030.6141@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701260745030.6141@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Nikita Danilov <nikita@clusterfs.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 26 Jan 2007, Nick Piggin wrote:
> 
> 
>>So you no longer account for reclaimable slab allocations, which
>>would be a significant change on some workloads. Any reason for
>>that?
> 
> 
> We could add NR_SLAB_RECLAIMABLE if that is a factor. However, 
> these pages cannot be dirtied. They may be reclaimed yes and then pages 
> may become available again. However, that is a difficult process without
> slab defrag. Are you sure that these are significant?

I think so. I have seen systems that get very full of dcache/icache, and
little to no pagecache. In that case it makes no sense to limit dirty
pages to a potentially small amount.

Slab reclaim does work. It may not be perfect, but I don't think that
should spill over into dirty page calculations. If anything we need to
improve slab reclaimability estimates for that.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
