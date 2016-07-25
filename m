Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EAD9F6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 04:00:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y134so384645912pfg.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 01:00:45 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id jh2si32346738pac.238.2016.07.25.01.00.44
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 01:00:45 -0700 (PDT)
Date: Mon, 25 Jul 2016 17:01:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: add per-zone lru list stat -fix
Message-ID: <20160725080114.GA1660@bbox>
References: <20160725072300.GK10438@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160725072300.GK10438@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 25, 2016 at 08:23:00AM +0100, Mel Gorman wrote:
> This patch renames the zone LRU stats as printed in /proc/vmstat to avoid
> confusion. This keeps both the node and zone stats which normally will be
> redundant but should always be roughly in sync.
> 
> This is a fix to the mmotm patch mm-add-per-zone-lru-list-stat.patch
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Actually, I don't have any number to prove how much keeping the stat
both zone and node increases performance but I don't object it.

Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
