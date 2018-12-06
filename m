Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 509496B7962
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 05:09:52 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id g7so9433900plp.10
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 02:09:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38sor31730163pld.67.2018.12.06.02.09.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 02:09:51 -0800 (PST)
MIME-Version: 1.0
References: <20181205054828.183476-1-drinkcat@chromium.org>
 <20181205054828.183476-3-drinkcat@chromium.org> <5eddd264-5527-a98e-fc8b-31ea89f474db@suse.cz>
 <CANMq1KAL7TcVa4xF8=NdK2cs0VakEq5i6MyCvfmYTGCmJ78-ag@mail.gmail.com> <09f56edb-2dab-c023-2164-dd7b5cef6afb@suse.cz>
In-Reply-To: <09f56edb-2dab-c023-2164-dd7b5cef6afb@suse.cz>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Thu, 6 Dec 2018 18:09:39 +0800
Message-ID: <CANMq1KAJ7YvbpUvRqP0zEWY1_pC-TvHMZYn4FUj4A9Bpmv_jxg@mail.gmail.com>
Subject: Re: [PATCH v4 2/3] mm: Add support for kmem caches in DMA32 zone
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org, Matthew Wilcox <willy@infradead.org>

On Thu, Dec 6, 2018 at 5:37 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 12/6/18 4:49 AM, Nicolas Boichat wrote:
> >> So it would be fine even unchanged. The check would anyway need some
> >> more love to catch the same with __GFP_DMA to be consistent and cover
> >> all corner cases.
> > Yes, the test is not complete. If we really wanted this to be
> > accurate, we'd need to check that GFP_* exactly matches SLAB_CACHE_*.
> >
> > The only problem with dropping this is test that we should restore
> > GFP_DMA32 warning/errors somewhere else (as Christopher pointed out
> > here: https://lkml.org/lkml/2018/11/22/430), especially for kmalloc
> > case.
>
> I meant just dropping that patch hunk, not the whole test. Then the test
> stays as it is and will keep warning anyone calling kmalloc(GFP_DMA32).
> It would also warn anyone calling kmem_cache_alloc(GFP_DMA32) on
> SLAB_CACHE_DMA32 cache, but since the gfp can be just dropped, and you
> as the only user of this so far will do that, it's fine?

I missed your point, this would work fine indeed.

Thanks.

> > Maybe this can be done in kmalloc_slab.
