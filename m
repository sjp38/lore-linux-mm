Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 098F16B741D
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 06:37:27 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id k58so9719026eda.20
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 03:37:26 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j10-v6si1032542eja.168.2018.12.05.03.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 03:37:25 -0800 (PST)
Date: Wed, 5 Dec 2018 12:37:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 2/3] mm: Add support for kmem caches in DMA32 zone
Message-ID: <20181205113722.GG1286@dhcp22.suse.cz>
References: <20181205054828.183476-1-drinkcat@chromium.org>
 <20181205054828.183476-3-drinkcat@chromium.org>
 <20181205095557.GE1286@dhcp22.suse.cz>
 <CANMq1KCnpSUKoz83LcEgAkhCi8QVPH715xtgdQD23r-tYusrPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANMq1KCnpSUKoz83LcEgAkhCi8QVPH715xtgdQD23r-tYusrPw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Boichat <drinkcat@chromium.org>
Cc: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org, Matthew Wilcox <willy@infradead.org>

On Wed 05-12-18 19:01:03, Nicolas Boichat wrote:
[...]
> > Secondly, why do we need a new sysfs file? Who is going to consume it?
> 
> We have cache_dma, so it seems consistent to add cache_dma32.

I wouldn't copy a pattern unless there is an explicit usecase for it.
We do expose way too much to userspace and that keeps kicking us later.
Not that I am aware of any specific example for cache_dma but seeing
other examples I would rather be more careful.

> I wasn't aware of tools/vm/slabinfo.c, so I can add support for
> cache_dma32 in a follow-up patch. Any other user I should take care
> of?

In general zones are inernal MM implementation details and the less we
export to userspace the better.

> > Then why do we need SLAB_MERGE_SAME to cover GFP_DMA32 as well?
> 
> SLAB_MERGE_SAME tells us which flags _need_ to be the same for the
> slabs to be merged. We don't want slab caches with GFP_DMA32 and
> ~GFP_DMA32 to be merged, so it should be in there.
> (https://elixir.bootlin.com/linux/v4.19.6/source/mm/slab_common.c#L342).

Ohh, my bad, I have misread the change. Sure we definitely not want to
allow merging here. My bad.
-- 
Michal Hocko
SUSE Labs
