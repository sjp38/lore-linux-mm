Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1E396B7A64
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 09:10:33 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id e68so331158plb.3
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 06:10:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y7si351286pgc.236.2018.12.06.06.10.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 06:10:32 -0800 (PST)
Date: Thu, 6 Dec 2018 06:10:10 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 07/34] powerpc/dma: remove the no-op
 dma_nommu_unmap_{page, sg} routines
Message-ID: <20181206141010.GF29741@infradead.org>
References: <20181114082314.8965-1-hch@lst.de>
 <20181114082314.8965-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114082314.8965-8-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

ping?

On Wed, Nov 14, 2018 at 09:22:47AM +0100, Christoph Hellwig wrote:
> These methods are optional, no need to implement no-op versions.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>  arch/powerpc/kernel/dma.c | 16 ----------------
>  1 file changed, 16 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
> index d6deb458bb91..7078d72baec2 100644
> --- a/arch/powerpc/kernel/dma.c
> +++ b/arch/powerpc/kernel/dma.c
> @@ -197,12 +197,6 @@ static int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
>  	return nents;
>  }
>  
> -static void dma_nommu_unmap_sg(struct device *dev, struct scatterlist *sg,
> -				int nents, enum dma_data_direction direction,
> -				unsigned long attrs)
> -{
> -}
> -
>  static u64 dma_nommu_get_required_mask(struct device *dev)
>  {
>  	u64 end, mask;
> @@ -228,14 +222,6 @@ static inline dma_addr_t dma_nommu_map_page(struct device *dev,
>  	return page_to_phys(page) + offset + get_dma_offset(dev);
>  }
>  
> -static inline void dma_nommu_unmap_page(struct device *dev,
> -					 dma_addr_t dma_address,
> -					 size_t size,
> -					 enum dma_data_direction direction,
> -					 unsigned long attrs)
> -{
> -}
> -
>  #ifdef CONFIG_NOT_COHERENT_CACHE
>  static inline void dma_nommu_sync_sg(struct device *dev,
>  		struct scatterlist *sgl, int nents,
> @@ -261,10 +247,8 @@ const struct dma_map_ops dma_nommu_ops = {
>  	.free				= dma_nommu_free_coherent,
>  	.mmap				= dma_nommu_mmap_coherent,
>  	.map_sg				= dma_nommu_map_sg,
> -	.unmap_sg			= dma_nommu_unmap_sg,
>  	.dma_supported			= dma_nommu_dma_supported,
>  	.map_page			= dma_nommu_map_page,
> -	.unmap_page			= dma_nommu_unmap_page,
>  	.get_required_mask		= dma_nommu_get_required_mask,
>  #ifdef CONFIG_NOT_COHERENT_CACHE
>  	.sync_single_for_cpu 		= dma_nommu_sync_single,
> -- 
> 2.19.1
> 
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu
---end quoted text---
