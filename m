Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3166B7A62
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 09:10:13 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id p9so400516pfj.3
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 06:10:13 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j10si386147plg.123.2018.12.06.06.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 06:10:12 -0800 (PST)
Date: Thu, 6 Dec 2018 06:10:00 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 04/34] powerpc/dma: remove the unused ISA_DMA_THRESHOLD
 export
Message-ID: <20181206141000.GD29741@infradead.org>
References: <20181114082314.8965-1-hch@lst.de>
 <20181114082314.8965-5-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114082314.8965-5-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

ping?

On Wed, Nov 14, 2018 at 09:22:44AM +0100, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>  arch/powerpc/kernel/setup_32.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
> index 81909600013a..07f7e6aaf104 100644
> --- a/arch/powerpc/kernel/setup_32.c
> +++ b/arch/powerpc/kernel/setup_32.c
> @@ -59,7 +59,6 @@ unsigned long ISA_DMA_THRESHOLD;
>  unsigned int DMA_MODE_READ;
>  unsigned int DMA_MODE_WRITE;
>  
> -EXPORT_SYMBOL(ISA_DMA_THRESHOLD);
>  EXPORT_SYMBOL(DMA_MODE_READ);
>  EXPORT_SYMBOL(DMA_MODE_WRITE);
>  
> -- 
> 2.19.1
> 
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu
---end quoted text---
