Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8522A6B26FE
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 13:32:59 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id x125so7140752qka.17
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 10:32:59 -0800 (PST)
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id v11si9828439qvq.113.2018.11.21.10.32.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Nov 2018 10:32:58 -0800 (PST)
Date: Wed, 21 Nov 2018 18:32:58 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 2/3] mm: Add support for SLAB_CACHE_DMA32
In-Reply-To: <20181111090341.120786-3-drinkcat@chromium.org>
Message-ID: <01000167378bf31a-a639b46c-4d1d-43de-9bed-9cdd9c07fa94-000000@email.amazonses.com>
References: <20181111090341.120786-1-drinkcat@chromium.org> <20181111090341.120786-3-drinkcat@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Boichat <drinkcat@chromium.org>
Cc: Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

On Sun, 11 Nov 2018, Nicolas Boichat wrote:

> SLAB_CACHE_DMA32 is only available after explicit kmem_cache_create calls,
> no default cache is created for kmalloc. Add a test in check_slab_flags
> for this.

This does not define the dma32 kmalloc array. Is that intentional? In that
case you need to fail any request for GFP_DMA32 coming in via kmalloc.
