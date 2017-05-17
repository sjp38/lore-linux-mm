Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CDBB66B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 03:44:34 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 123so3675008pge.14
        for <linux-mm@kvack.org>; Wed, 17 May 2017 00:44:34 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id s1si1367538plk.256.2017.05.17.00.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 00:44:34 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id s62so837456pgc.0
        for <linux-mm@kvack.org>; Wed, 17 May 2017 00:44:34 -0700 (PDT)
Date: Wed, 17 May 2017 16:44:26 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
Message-ID: <20170517074424.GC18406@js1304-desktop>
References: <20170425034255.GB32583@js1304-desktop>
 <20170427150636.GM4706@dhcp22.suse.cz>
 <20170502040129.GA27335@js1304-desktop>
 <20170502133229.GK14593@dhcp22.suse.cz>
 <20170511021240.GA22319@js1304-desktop>
 <20170511091304.GH26782@dhcp22.suse.cz>
 <20170512020046.GA5538@js1304-desktop>
 <20170512063815.GC6803@dhcp22.suse.cz>
 <20170515035712.GA11257@js1304-desktop>
 <20170516084734.GC2481@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170516084734.GC2481@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

> > 
> > Okay. We did a lot of discussion so it's better to summarise it.
> > 
> > 1. ZONE_CMA might be a nicer solution than MIGRATETYPE.
> > 2. Additional bit in page flags would cause another kind of
> > maintenance problem so it's better to avoid it as much as possible.
> > 3. Abusing ZONE_MOVABLE looks better than introducing ZONE_CMA since
> > it doesn't need additional bit in page flag.
> > 4. (Not-yet-finished) If ZONE_CMA doesn't need extra bit in page
> > flags with hacky magic and it has no performance regression,
> > ??? (it's okay to use separate zone for CMA?)
> 
> As mentioned above. I do not see why we should go over additional hops
> just to have a zone which is not strictly needed. So if there are no
> inherent problems reusing MOVABLE/HIGMEM zone then a separate zone
> sounds like a wrong direction.
> 
> But let me repeat. I am _not_ convinced that the migratetype situation
> is all that bad and unfixable. You have mentioned some issues with the
> current approach but none of them seem inherently unfixable. So I would
> still prefer keeping the current way. But I am not going to insist if
> you _really_ believe that the long term maintenance cost will be higher
> than a zone approach and you can reuse MOVABLE/HIGHMEM zones without
> disruptive changes. I can help you with the hotplug part of the MOVABLE
> zone because that is desirable on its own.

Okay. Thanks for sharing your opinion. I will decide the final
direction after some investigation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
