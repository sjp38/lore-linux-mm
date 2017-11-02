Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3BD6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 01:50:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p9so4856915pgc.6
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 22:50:22 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n11si1278402pls.746.2017.11.01.22.50.20
        for <linux-mm@kvack.org>;
        Wed, 01 Nov 2017 22:50:21 -0700 (PDT)
Date: Thu, 2 Nov 2017 14:50:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -V3] mm, swap: Fix false error message in
 __swp_swapcount()
Message-ID: <20171102055019.GA26929@bbox>
References: <20171102054225.22897-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171102054225.22897-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, stable@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>

On Thu, Nov 02, 2017 at 01:42:25PM +0800, Huang, Ying wrote:
> From: Huang Ying <huang.ying.caritas@gmail.com>
> 
> When a page fault occurs for a swap entry, the physical swap readahead
> (not the VMA base swap readahead) may readahead several swap entries
> after the fault swap entry.  The readahead algorithm calculates some
> of the swap entries to readahead via increasing the offset of the
> fault swap entry without checking whether they are beyond the end of
> the swap device and it relys on the __swp_swapcount() and
> swapcache_prepare() to check it.  Although __swp_swapcount() checks
> for the swap entry passed in, it will complain with the error message
> as follow for the expected invalid swap entry.  This may make the end
> users confused.
> 
>   swap_info_get: Bad swap offset entry 0200f8a7
> 
> To fix the false error message, the swap entry checking is added in
> swapin_readahead() to avoid to pass the out-of-bound swap entries and
> the swap entry reserved for the swap header to __swp_swapcount() and
> swapcache_prepare().
> 
> Cc: Tim Chen <tim.c.chen@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: <stable@vger.kernel.org> # 4.11-4.13
> Fixes: e8c26ab60598 ("mm/swap: skip readahead for unreferenced swap slots")
> Reported-by: Christian Kujau <lists@nerdbynature.de>
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
