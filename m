Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 23B786B74D5
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 09:45:47 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id k76so12549645oih.13
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 06:45:47 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d93si8543084otb.187.2018.12.05.06.45.46
        for <linux-mm@kvack.org>;
        Wed, 05 Dec 2018 06:45:46 -0800 (PST)
Date: Wed, 5 Dec 2018 14:46:06 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v4 3/3] iommu/io-pgtable-arm-v7s: Request DMA32 memory,
 and improve debugging
Message-ID: <20181205144605.GA16171@arm.com>
References: <20181205054828.183476-1-drinkcat@chromium.org>
 <20181205054828.183476-4-drinkcat@chromium.org>
 <20181205135406.GA29031@infradead.org>
 <1d211576-9153-cca1-5cd0-8c9881bd3fa4@arm.com>
 <20181205144308.GA28409@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205144308.GA28409@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Robin Murphy <robin.murphy@arm.com>, Nicolas Boichat <drinkcat@chromium.org>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, Matthew Wilcox <willy@infradead.org>

On Wed, Dec 05, 2018 at 06:43:08AM -0800, Christoph Hellwig wrote:
> On Wed, Dec 05, 2018 at 02:40:06PM +0000, Robin Murphy wrote:
> > 32-bit Arm doesn't have ZONE_DMA32, but has (or at least had at the time) a
> > 2GB ZONE_DMA. Whether we actually need that or not depends on how this all
> > interacts with LPAE and highmem, but I'm not sure of those details off-hand.
> 
> Well, arm32 can't address more than 32-bits in the linear kernel
> mapping, so GFP_KERNEL should be perfectly fine there if the limit
> really is 32-bits and not 31 or smaller because someone stole a bit
> or two somewhere.

I'm not sure that's necessarily true on the physical side. Wasn't there a
keystone SoC with /all/ the coherent memory above 4GB?

Will
