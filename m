Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 10F97829BE
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 11:23:17 -0400 (EDT)
Received: by wghk14 with SMTP id k14so24028948wgh.3
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 08:23:16 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id br4si3554804wjb.55.2015.03.13.08.23.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 08:23:15 -0700 (PDT)
Received: by wiwl15 with SMTP id l15so6909727wiw.0
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 08:23:14 -0700 (PDT)
Date: Fri, 13 Mar 2015 16:23:11 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: kswapd hogging in lowmem_shrink
Message-ID: <20150313152311.GF4881@dhcp22.suse.cz>
References: <CAB5gotvwyD74UugjB6XQ_v=o11Hu9wAuA6N94UvGObPARYEz0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAB5gotvwyD74UugjB6XQ_v=o11Hu9wAuA6N94UvGObPARYEz0w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaibhav Shinde <v.bhav.shinde@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

On Fri 13-03-15 19:55:27, Vaibhav Shinde wrote:
> On low memory situation, I see various shrinkers being invoked, but in
> lowmem_shrink() case, kswapd is found to be hogging for around 150msecs.
> 
> Due to this my application suffer latency issue, as the cpu was not
> released by kswapd0.
> 
> I took below traces with vmscan events, that show lowmem_shrink taking such
> long time for execution.
> 
> kswapd0-67 [003] ...1  1501.987110: mm_shrink_slab_start:
> lowmem_shrink+0x0/0x580 c0ee8e34: objects to shrink 122 gfp_flags
> GFP_KERNEL pgs_scanned 83 lru_pgs 241753 cache items 241754 delta 10
> total_scan 132
> kswapd0-67 [003] ...1  1502.020827: mm_shrink_slab_end:
> lowmem_shrink+0x0/0x580 c0ee8e34: unused scan count 122 new scan count 4
> total_scan -118 last shrinker return val 237339
> 
> Please provide inputs on the same.

I would strongly discourage from using lowmemory killer. It is broken by
design IMHO. It can spend a lot of time looping on a large machine. Why
do you use it in the first place?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
