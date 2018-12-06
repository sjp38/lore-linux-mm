Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 261C46B7A10
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 09:10:13 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id o23so333966pll.0
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 06:10:13 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k38si352157pgi.235.2018.12.06.06.10.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 06:10:11 -0800 (PST)
Date: Thu, 6 Dec 2018 06:10:04 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 05/34] powerpc/dma: remove the unused dma_iommu_ops export
Message-ID: <20181206141004.GE29741@infradead.org>
References: <20181114082314.8965-1-hch@lst.de>
 <20181114082314.8965-6-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114082314.8965-6-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

ping?

On Wed, Nov 14, 2018 at 09:22:45AM +0100, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/powerpc/kernel/dma-iommu.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/dma-iommu.c b/arch/powerpc/kernel/dma-iommu.c
> index f9fe2080ceb9..2ca6cfaebf65 100644
> --- a/arch/powerpc/kernel/dma-iommu.c
> +++ b/arch/powerpc/kernel/dma-iommu.c
> @@ -6,7 +6,6 @@
>   * busses using the iommu infrastructure
>   */
>  
> -#include <linux/export.h>
>  #include <asm/iommu.h>
>  
>  /*
> @@ -123,4 +122,3 @@ struct dma_map_ops dma_iommu_ops = {
>  	.get_required_mask	= dma_iommu_get_required_mask,
>  	.mapping_error		= dma_iommu_mapping_error,
>  };
> -EXPORT_SYMBOL(dma_iommu_ops);
> -- 
> 2.19.1
> 
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu
---end quoted text---
