Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 194AD6B7A63
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 09:10:19 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id y88so390580pfi.9
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 06:10:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e6si354497pgl.471.2018.12.06.06.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 06:10:18 -0800 (PST)
Date: Thu, 6 Dec 2018 06:09:55 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 03/34] powerpc/dma: remove the unused
 ARCH_HAS_DMA_MMAP_COHERENT define
Message-ID: <20181206140955.GC29741@infradead.org>
References: <20181114082314.8965-1-hch@lst.de>
 <20181114082314.8965-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114082314.8965-4-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

ping?

On Wed, Nov 14, 2018 at 09:22:43AM +0100, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>  arch/powerpc/include/asm/dma-mapping.h | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
> index 8fa394520af6..f2a4a7142b1e 100644
> --- a/arch/powerpc/include/asm/dma-mapping.h
> +++ b/arch/powerpc/include/asm/dma-mapping.h
> @@ -112,7 +112,5 @@ extern int dma_set_mask(struct device *dev, u64 dma_mask);
>  
>  extern u64 __dma_get_required_mask(struct device *dev);
>  
> -#define ARCH_HAS_DMA_MMAP_COHERENT
> -
>  #endif /* __KERNEL__ */
>  #endif	/* _ASM_DMA_MAPPING_H */
> -- 
> 2.19.1
> 
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu
---end quoted text---
