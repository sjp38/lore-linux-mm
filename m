Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86F386B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 08:37:34 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id ez4so32978397wjd.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 05:37:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e191si2462148wmf.158.2017.02.08.05.37.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 05:37:33 -0800 (PST)
Date: Wed, 8 Feb 2017 14:37:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmscan: Skip slab scan when LRU size is zero
Message-ID: <20170208133732.GM5686@dhcp22.suse.cz>
References: <1837390276.846271.1486216381871.ref@mail.yahoo.com>
 <1837390276.846271.1486216381871@mail.yahoo.com>
 <20170206083028.GB3085@dhcp22.suse.cz>
 <16b94242-095e-ac71-cb27-a20f2f2c2100@yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16b94242-095e-ac71-cb27-a20f2f2c2100@yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shantanu Goel <sgoel01@yahoo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 06-02-17 19:47:49, Shantanu Goel wrote:
[...]
> #                              _-----=> irqs-off
> #                             / _----=> need-resched
> #                            | / _---=> hardirq/softirq
> #                            || / _--=> preempt-depth
> #                            ||| /     delay
> #           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
> #              | |       |   ||||       |         |
[...]
All previous entries are for super_cache_scan so they will not tell us
much about the previous state of scan_shadow_nodes so this output seems
incomplete. Could you also enable mm_shrink_slab_end tracepoint please?

>          kswapd0-93    [005] .... 49736.760169: mm_shrink_slab_start:
> scan_shadow_nodes+0x0/0x50 ffffffff94e6e460: nid: 0 objects to shrink
> 59291940 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 0 cache items 20 delta
> 1280 total_scan 40
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
