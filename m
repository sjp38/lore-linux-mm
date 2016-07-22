Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D08D16B0253
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 11:57:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b65so37626394wmg.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:57:48 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t185si10513706wma.107.2016.07.22.08.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jul 2016 08:57:47 -0700 (PDT)
Date: Fri, 22 Jul 2016 11:57:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/5] mm: Remove reclaim and compaction retry
 approximations
Message-ID: <20160722155740.GD23650@cmpxchg.org>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
 <1469110261-7365-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469110261-7365-4-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2016 at 03:10:59PM +0100, Mel Gorman wrote:
> If per-zone LRU accounting is available then there is no point
> approximating whether reclaim and compaction should retry based on pgdat
> statistics. This is effectively a revert of "mm, vmstat: remove zone and
> node double accounting by approximating retries" with the difference that
> inactive/active stats are still available. This preserves the history of
> why the approximation was retried and why it had to be reverted to handle
> OOM kills on 32-bit systems.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

I like this version of should_reclaim_retry() much better ;)

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
