Message-ID: <45B9F26D.5090107@yahoo.com.au>
Date: Fri, 26 Jan 2007 23:22:05 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC 0/8] Use ZVCs for accurate writeback ratio determination
References: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Nikita Danilov <nikita@clusterfs.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> The determination of the dirty ratio to determine writeback behavior
> is currently based on the number of total pages on the system.
> 
> However, not all pages in the system may be dirtied. Thus the ratio
> is always too low and can never reach 100%. The ratio may be
> particularly skewed if large hugepage allocations, slab allocations
> or device driver buffers make large sections of memory not available
> anymore. In that case we may get into a situation in which f.e. the
> background writeback ratio of 40% cannot be reached anymore which
> leads to undesired writeback behavior.
> 
> This patchset fixes that issue by determining the ratio based
> on the actual pages that may potentially be dirty. These are
> the pages on the active and the inactive list plus free pages.

So you no longer account for reclaimable slab allocations, which
would be a significant change on some workloads. Any reason for
that?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
