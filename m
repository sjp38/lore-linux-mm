Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB47B6B26C6
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 12:38:31 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id j125so7007225qke.12
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 09:38:31 -0800 (PST)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id u37si26193744qta.385.2018.11.21.09.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Nov 2018 09:38:30 -0800 (PST)
Date: Wed, 21 Nov 2018 17:38:30 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/3] iommu/io-pgtable-arm-v7s: Request DMA32 memory,
 and improve debugging
In-Reply-To: <20181121164638.GD24883@arm.com>
Message-ID: <01000167375a15f8-362aa1e2-cf01-49b5-92b5-f0a4efcca477-000000@email.amazonses.com>
References: <20181111090341.120786-1-drinkcat@chromium.org> <20181111090341.120786-4-drinkcat@chromium.org> <20181121164638.GD24883@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Nicolas Boichat <drinkcat@chromium.org>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

On Wed, 21 Nov 2018, Will Deacon wrote:

> > +#define ARM_V7S_TABLE_SLAB_CACHE SLAB_CACHE_DMA32

SLAB_CACHE_DMA32??? WTH is going on here? We are trying to get rid of
the dma slab array.
