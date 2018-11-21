Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A24B26B26F4
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 13:18:24 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 42so4017810qtr.7
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 10:18:24 -0800 (PST)
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id p9si6253129qvq.61.2018.11.21.10.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Nov 2018 10:18:23 -0800 (PST)
Date: Wed, 21 Nov 2018 18:18:23 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/3] iommu/io-pgtable-arm-v7s: Request DMA32 memory,
 and improve debugging
In-Reply-To: <a034e2c3-8933-caba-a113-ca08372da2b9@arm.com>
Message-ID: <01000167377e99b6-10666044-2e7d-4af3-9cae-9db9c1a9b279-000000@email.amazonses.com>
References: <20181111090341.120786-1-drinkcat@chromium.org> <20181111090341.120786-4-drinkcat@chromium.org> <20181121164638.GD24883@arm.com> <01000167375a15f8-362aa1e2-cf01-49b5-92b5-f0a4efcca477-000000@email.amazonses.com>
 <a034e2c3-8933-caba-a113-ca08372da2b9@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Nicolas Boichat <drinkcat@chromium.org>, Joerg Roedel <joro@8bytes.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

On Wed, 21 Nov 2018, Robin Murphy wrote:

> On 21/11/2018 17:38, Christopher Lameter wrote:
> > On Wed, 21 Nov 2018, Will Deacon wrote:
> >
> > > > +#define ARM_V7S_TABLE_SLAB_CACHE SLAB_CACHE_DMA32
> >
> > SLAB_CACHE_DMA32??? WTH is going on here? We are trying to get rid of
> > the dma slab array.
>
> See the previous two patches in this series. If there's already a (better) way
> to have a kmem_cache which allocates its backing pages with GFP_DMA32, please
> do let us know.

Was not cced on the whole patchset. Trying to find it. Its best to
allocate DMA memory through the page based allocation functions.
dma_alloc_coherent() and friends.
