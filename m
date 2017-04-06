Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADDE86B043D
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 11:41:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id t30so6702133wrc.15
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 08:41:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h63si29587660wme.66.2017.04.06.08.41.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 08:41:32 -0700 (PDT)
Date: Thu, 6 Apr 2017 17:41:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170406154127.GQ5497@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170406130846.GL5497@dhcp22.suse.cz>
 <20170406152449.zmghwdb4y6hxn4pm@arbab-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170406152449.zmghwdb4y6hxn4pm@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu 06-04-17 10:24:49, Reza Arbab wrote:
> On Thu, Apr 06, 2017 at 03:08:46PM +0200, Michal Hocko wrote:
> >OK, so after recent change mostly driven by testing from Reza Arbab
> >(thanks again) I believe I am getting to a working state finally. All I
> >currently have is
> >in git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git tree
> >attempts/rewrite-mem_hotplug-WIP branch. I will highly appreciate more
> >testing of course and if there are no new issues found I will repost the
> >series for the review.
> 
> Looking good! I can do my add/remove/repeat test and things seem fine.
> 
> One thing--starting on the second iteration, I am seeing the WARN in
> free_area_init_node();
> 
> add_memory
>  add_memory_resource
>    hotadd_new_pgdat
>      free_area_init_node
> 	WARN_ON(pgdat->nr_zones || pgdat->kswapd_classzone_idx);

Have you tested with my attempts/rewrite-mem_hotplug-WIP mentioned
elsewhere? Because I suspect that "mm: get rid of zone_is_initialized"
might cause this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
