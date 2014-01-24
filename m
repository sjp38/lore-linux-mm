Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 890966B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 18:05:25 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c41so1229033eek.16
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 15:05:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id d41si4697252eep.197.2014.01.24.15.05.23
        for <linux-mm@kvack.org>;
        Fri, 24 Jan 2014 15:05:24 -0800 (PST)
Message-ID: <52E2F1A5.7010907@redhat.com>
Date: Fri, 24 Jan 2014 18:05:09 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/2] mm: page-writeback: fix dirty_balance_reserve subtraction
 from dirtyable memory
References: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org> <1390600984-13925-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1390600984-13925-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 01/24/2014 05:03 PM, Johannes Weiner wrote:
> The dirty_balance_reserve is an approximation of the fraction of free
> pages that the page allocator does not make available for page cache
> allocations.  As a result, it has to be taken into account when
> calculating the amount of "dirtyable memory", the baseline to which
> dirty_background_ratio and dirty_ratio are applied.
> 
> However, currently the reserve is subtracted from the sum of free and
> reclaimable pages, which is non-sensical and leads to erroneous
> results when the system is dominated by unreclaimable pages and the
> dirty_balance_reserve is bigger than free+reclaimable.  In that case,
> at least the already allocated cache should be considered dirtyable.
> 
> Fix the calculation by subtracting the reserve from the amount of free
> pages, then adding the reclaimable pages on top.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
