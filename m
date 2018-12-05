Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54D586B74D3
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 09:43:23 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id d23so14971657plj.22
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 06:43:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z10si21225985pfm.37.2018.12.05.06.43.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Dec 2018 06:43:22 -0800 (PST)
Date: Wed, 5 Dec 2018 06:43:08 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 3/3] iommu/io-pgtable-arm-v7s: Request DMA32 memory,
 and improve debugging
Message-ID: <20181205144308.GA28409@infradead.org>
References: <20181205054828.183476-1-drinkcat@chromium.org>
 <20181205054828.183476-4-drinkcat@chromium.org>
 <20181205135406.GA29031@infradead.org>
 <1d211576-9153-cca1-5cd0-8c9881bd3fa4@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d211576-9153-cca1-5cd0-8c9881bd3fa4@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@infradead.org>, Nicolas Boichat <drinkcat@chromium.org>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, Matthew Wilcox <willy@infradead.org>

On Wed, Dec 05, 2018 at 02:40:06PM +0000, Robin Murphy wrote:
> 32-bit Arm doesn't have ZONE_DMA32, but has (or at least had at the time) a
> 2GB ZONE_DMA. Whether we actually need that or not depends on how this all
> interacts with LPAE and highmem, but I'm not sure of those details off-hand.

Well, arm32 can't address more than 32-bits in the linear kernel
mapping, so GFP_KERNEL should be perfectly fine there if the limit
really is 32-bits and not 31 or smaller because someone stole a bit
or two somewhere.
