Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA8736B025E
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 03:06:06 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b1so954059068pgc.5
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 00:06:06 -0800 (PST)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id 15si52738163pfk.17.2016.12.29.00.06.04
        for <linux-mm@kvack.org>;
        Thu, 29 Dec 2016 00:06:05 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161228153032.10821-1-mhocko@kernel.org> <20161228153032.10821-7-mhocko@kernel.org>
In-Reply-To: <20161228153032.10821-7-mhocko@kernel.org>
Subject: Re: [PATCH 6/7] mm, vmscan: enhance mm_vmscan_lru_shrink_inactive tracepoint
Date: Thu, 29 Dec 2016 16:05:49 +0800
Message-ID: <06da01d261aa$5e7b01e0$1b7105a0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, linux-mm@kvack.org
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Rik van Riel' <riel@redhat.com>, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>



On Wednesday, December 28, 2016 11:31 PM Michal Hocko wrote: 
> From: Michal Hocko <mhocko@suse.com>
> 
> mm_vmscan_lru_shrink_inactive will currently report the number of
> scanned and reclaimed pages. This doesn't give us an idea how the
> reclaim went except for the overall effectiveness though. Export
> and show other counters which will tell us why we couldn't reclaim
> some pages.
> 	- nr_dirty, nr_writeback, nr_congested and nr_immediate tells
> 	  us how many pages are blocked due to IO
> 	- nr_activate tells us how many pages were moved to the active
> 	  list
> 	- nr_ref_keep reports how many pages are kept on the LRU due
> 	  to references (mostly for the file pages which are about to
> 	  go for another round through the inactive list)
> 	- nr_unmap_fail - how many pages failed to unmap
> 
> All these are rather low level so they might change in future but the
> tracepoint is already implementation specific so no tools should be
> depending on its stability.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
