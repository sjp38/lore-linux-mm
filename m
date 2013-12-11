Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id B58E66B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 13:24:45 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id b57so3087454eek.40
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 10:24:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r9si20333388eeo.107.2013.12.11.10.24.44
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 10:24:44 -0800 (PST)
Message-ID: <52A8ADE4.8020609@redhat.com>
Date: Wed, 11 Dec 2013 13:24:36 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: page_alloc: exclude unreclaimable allocations from
 zone fairness policy
References: <1386785356-19911-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1386785356-19911-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/11/2013 01:09 PM, Johannes Weiner wrote:
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
> Bisected-by: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: <stable@kernel.org>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
