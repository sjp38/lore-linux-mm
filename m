Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 44AF76B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 04:51:15 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id e7so55514274lfe.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 01:51:15 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id aq5si4591069wjc.126.2016.09.01.01.51.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Sep 2016 01:51:13 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id DD9E49930D
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 08:51:12 +0000 (UTC)
Date: Thu, 1 Sep 2016 09:51:11 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH -v2] mm: Don't use radix tree writeback tags for pages in
 swap cache
Message-ID: <20160901085111.GC8119@techsingularity.net>
References: <1472578089-5560-1-git-send-email-ying.huang@intel.com>
 <20160831091459.GY8119@techsingularity.net>
 <20160831143031.4e5a180f969ec6997637a96f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160831143031.4e5a180f969ec6997637a96f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

On Wed, Aug 31, 2016 at 02:30:31PM -0700, Andrew Morton wrote:
> On Wed, 31 Aug 2016 10:14:59 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > >    2506952 __  2%     +28.1%    3212076 __  7%  vm-scalability.throughput
> > >    1207402 __  7%     +22.3%    1476578 __  6%  vmstat.swap.so
> > >      10.86 __ 12%     -23.4%       8.31 __ 16%  perf-profile.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list
> > >      10.82 __ 13%     -33.1%       7.24 __ 14%  perf-profile.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_zone_memcg
> > >      10.36 __ 11%    -100.0%       0.00 __ -1%  perf-profile.cycles-pp._raw_spin_lock_irqsave.__test_set_page_writeback.bdev_write_page.__swap_writepage.swap_writepage
> > >      10.52 __ 12%    -100.0%       0.00 __ -1%  perf-profile.cycles-pp._raw_spin_lock_irqsave.test_clear_page_writeback.end_page_writeback.page_endio.pmem_rw_page
> > > 
> > 
> > I didn't see anything wrong with the patch but it's worth highlighting
> > that this hunk means we are now out of GFP bits.
> 
> Well ugh.  What are we to do about that?
> 

It'll stop silent breakage so

Acked-by: Mel Gorman <mgorman@techsingularity.net>

Whoever hits it will need to take similar steps we had to with page->flags
by making some 64-bit only, removing flags or inferring the flag values
from other sources.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
