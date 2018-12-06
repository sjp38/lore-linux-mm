Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 98C5E6B7A67
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 09:11:11 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id h9so312164pgm.1
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 06:11:11 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n8si357828plp.137.2018.12.06.06.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 06:11:10 -0800 (PST)
Date: Thu, 6 Dec 2018 06:10:45 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 19/34] cxl: drop the dma_set_mask callback from vphb
Message-ID: <20181206141045.GI29741@infradead.org>
References: <20181114082314.8965-1-hch@lst.de>
 <20181114082314.8965-20-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114082314.8965-20-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

ping?

On Wed, Nov 14, 2018 at 09:22:59AM +0100, Christoph Hellwig wrote:
> The CXL code never even looks at the dma mask, so there is no good
> reason for this sanity check.  Remove it because it gets in the way
> of the dma ops refactoring.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/misc/cxl/vphb.c | 12 ------------
>  1 file changed, 12 deletions(-)
> 
> diff --git a/drivers/misc/cxl/vphb.c b/drivers/misc/cxl/vphb.c
> index 7908633d9204..49da2f744bbf 100644
> --- a/drivers/misc/cxl/vphb.c
> +++ b/drivers/misc/cxl/vphb.c
> @@ -11,17 +11,6 @@
>  #include <misc/cxl.h>
>  #include "cxl.h"
>  
> -static int cxl_dma_set_mask(struct pci_dev *pdev, u64 dma_mask)
> -{
> -	if (dma_mask < DMA_BIT_MASK(64)) {
> -		pr_info("%s only 64bit DMA supported on CXL", __func__);
> -		return -EIO;
> -	}
> -
> -	*(pdev->dev.dma_mask) = dma_mask;
> -	return 0;
> -}
> -
>  static int cxl_pci_probe_mode(struct pci_bus *bus)
>  {
>  	return PCI_PROBE_NORMAL;
> @@ -220,7 +209,6 @@ static struct pci_controller_ops cxl_pci_controller_ops =
>  	.reset_secondary_bus = cxl_pci_reset_secondary_bus,
>  	.setup_msi_irqs = cxl_setup_msi_irqs,
>  	.teardown_msi_irqs = cxl_teardown_msi_irqs,
> -	.dma_set_mask = cxl_dma_set_mask,
>  };
>  
>  int cxl_pci_vphb_add(struct cxl_afu *afu)
> -- 
> 2.19.1
> 
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu
---end quoted text---
