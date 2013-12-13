Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3526C6B00B3
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 10:45:59 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id hq4so1274825wib.9
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 07:45:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k1si973695wjz.126.2013.12.13.07.45.57
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 07:45:58 -0800 (PST)
Message-ID: <52AB2BAD.4080003@redhat.com>
Date: Fri, 13 Dec 2013 10:45:49 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] mm: page_alloc: exclude unreclaimable allocations
 from zone fairness policy
References: <1386943807-29601-1-git-send-email-mgorman@suse.de> <1386943807-29601-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1386943807-29601-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/13/2013 09:10 AM, Mel Gorman wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> Dave Hansen noted a regression in a microbenchmark that loops around
> open() and close() on an 8-node NUMA machine and bisected it down to
> 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy").  That
> change forces the slab allocations of the file descriptor to spread
> out to all 8 nodes, causing remote references in the page allocator
> and slab.
> 
> The round-robin policy is only there to provide fairness among memory
> allocations that are reclaimed involuntarily based on pressure in each
> zone.  It does not make sense to apply it to unreclaimable kernel
> allocations that are freed manually, in this case instantly after the
> allocation, and incur the remote reference costs twice for no reason.
> 
> Only round-robin allocations that are usually freed through page
> reclaim or slab shrinking.
> 
> Cc: <stable@kernel.org>
> Bisected-by: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
