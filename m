Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E5C6E6B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 05:13:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id e7so55982528lfe.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 02:13:50 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id e125si28505247wma.60.2016.09.01.02.13.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 02:13:49 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w207so7434567wmw.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 02:13:49 -0700 (PDT)
Date: Thu, 1 Sep 2016 11:13:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -v2] mm: Don't use radix tree writeback tags for pages in
 swap cache
Message-ID: <20160901091347.GC12147@dhcp22.suse.cz>
References: <1472578089-5560-1-git-send-email-ying.huang@intel.com>
 <20160831091459.GY8119@techsingularity.net>
 <20160831143031.4e5a180f969ec6997637a96f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160831143031.4e5a180f969ec6997637a96f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, "Huang, Ying" <ying.huang@intel.com>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

On Wed 31-08-16 14:30:31, Andrew Morton wrote:
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

Can we simply give these AS_ flags their own word in mapping rather than
squash them together with gfp flags and impose the restriction on the
number of gfp flags. There was some demand for new gfp flags already and
mapping flags were in the way.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
