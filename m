Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD8246B0253
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 20:57:21 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id sq19so61028702igc.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 17:57:21 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id s124si6220829ios.186.2016.04.26.17.57.20
        for <linux-mm@kvack.org>;
        Tue, 26 Apr 2016 17:57:21 -0700 (PDT)
Date: Wed, 27 Apr 2016 09:57:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 4.6 1/3] mm, cma: prevent nr_isolated_* counters from
 going negative
Message-ID: <20160427005718.GB6336@js1304-P5Q-DELUXE>
References: <1461591269-28615-1-git-send-email-vbabka@suse.cz>
 <1461591350-28700-1-git-send-email-vbabka@suse.cz>
 <1461591350-28700-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461591350-28700-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, stable@vger.kernel.org

On Mon, Apr 25, 2016 at 03:35:48PM +0200, Vlastimil Babka wrote:
> From: Hugh Dickins <hughd@google.com>
> 
> /proc/sys/vm/stat_refresh warns nr_isolated_anon and nr_isolated_file
> go increasingly negative under compaction: which would add delay when
> should be none, or no delay when should delay. The bug in compaction was
> due to a recent mmotm patch, but much older instance of the bug was also
> noticed in isolate_migratepages_range() which is used for CMA and
> gigantic hugepage allocations.
> 
> The bug is caused by putback_movable_pages() in an error path decrementing
> the isolated counters without them being previously incremented by
> acct_isolated(). Fix isolate_migratepages_range() by removing the error-path
> putback, thus reaching acct_isolated() with migratepages still isolated, and
> leaving putback to caller like most other places do.
> 
> [vbabka@suse.cz: expanded the changelog]
> Fixes: edc2ca612496 ("mm, compaction: move pageblock checks up from isolate_migratepages_range()")
> Cc: stable@vger.kernel.org
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
