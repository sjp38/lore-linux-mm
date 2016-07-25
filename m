Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8ABA16B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 04:17:54 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so319020363pab.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 01:17:54 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v187si32463300pfb.258.2016.07.25.01.17.53
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 01:17:53 -0700 (PDT)
Date: Mon, 25 Jul 2016 17:18:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/5] mm: Remove reclaim and compaction retry
 approximations
Message-ID: <20160725081820.GD1660@bbox>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
 <1469110261-7365-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1469110261-7365-4-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

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
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
