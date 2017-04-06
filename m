Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD3E46B0397
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 13:46:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v44so7211984wrc.9
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 10:46:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j185si3927913wmg.96.2017.04.06.10.46.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 10:46:40 -0700 (PDT)
Date: Thu, 6 Apr 2017 18:46:34 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170406174634.22owejtnema6bixm@suse.de>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170406130846.GL5497@dhcp22.suse.cz>
 <20170406152449.zmghwdb4y6hxn4pm@arbab-laptop>
 <20170406154127.GQ5497@dhcp22.suse.cz>
 <20170406154653.yv4i2k2r7hjq6mke@arbab-laptop>
 <20170406162154.GR5497@dhcp22.suse.cz>
 <20170406165520.qjdqclsm6zl6m6p3@suse.de>
 <20170406171242.GS5497@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170406171242.GS5497@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Apr 06, 2017 at 07:12:42PM +0200, Michal Hocko wrote:
> > ---8<---
> > mm, vmscan: prevent kswapd sleeping prematurely due to mismatched classzone_idx -fix
> > 
> > The patch "mm, vmscan: prevent kswapd sleeping prematurely due to mismatched
> > classzone_idx" has different initial starting conditions when kswapd
> > is asleep. kswapd initialises it properly when it starts but the patch
> > initialises kswapd_classzone_idx early and trips on a warning in
> > free_area_init_node. This patch leaves the kswapd_classzone_idx as zero
> > and defers to kswapd to initialise it properly when it starts.
> 
> It will start during the online phase which is later than this physical
> memory hotadd.
> 

Good, that's what appeared to be happening at least. It would be
somewhat insane if kswapd was running before zones were initialised.

> > This is a fix to the mmotm patch
> > mm-vmscan-prevent-kswapd-sleeping-prematurely-due-to-mismatched-classzone_idx.patch
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Yes, that is what I would expect. Feel free to add
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> if this is routed as a separate patch. Although I expect Andrew will
> fold it into the original patch.
> 

I added the ack anyway and resent the patch so it doesn't get lost in
the middle of a thread. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
