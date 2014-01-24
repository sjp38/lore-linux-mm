Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 590A46B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 18:26:06 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id w61so3264407wes.2
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 15:26:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t6si2209116wiy.23.2014.01.24.15.26.04
        for <linux-mm@kvack.org>;
        Fri, 24 Jan 2014 15:26:05 -0800 (PST)
Message-ID: <52E2F680.10409@redhat.com>
Date: Fri, 24 Jan 2014 18:25:52 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/2] mm: page-writeback: do not count anon pages as dirtyable
 memory
References: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org> <1390600984-13925-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1390600984-13925-3-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 01/24/2014 05:03 PM, Johannes Weiner wrote:
> The VM is currently heavily tuned to avoid swapping.  Whether that is
> good or bad is a separate discussion, but as long as the VM won't swap
> to make room for dirty cache, we can not consider anonymous pages when
> calculating the amount of dirtyable memory, the baseline to which
> dirty_background_ratio and dirty_ratio are applied.
> 
> A simple workload that occupies a significant size (40+%, depending on
> memory layout, storage speeds etc.) of memory with anon/tmpfs pages
> and uses the remainder for a streaming writer demonstrates this
> problem.  In that case, the actual cache pages are a small fraction of
> what is considered dirtyable overall, which results in an relatively
> large portion of the cache pages to be dirtied.  As kswapd starts
> rotating these, random tasks enter direct reclaim and stall on IO.
> 
> Only consider free pages and file pages dirtyable.
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
