Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 5797D6B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 09:15:44 -0500 (EST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MFP00IGH0Y1B320@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 27 Dec 2012 14:15:42 +0000 (GMT)
Received: from [127.0.0.1] ([106.116.147.30])
 by eusync4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MFP00GJL0Y4G780@eusync4.samsung.com> for linux-mm@kvack.org;
 Thu, 27 Dec 2012 14:15:42 +0000 (GMT)
Message-id: <50DC580C.7080507@samsung.com>
Date: Thu, 27 Dec 2012 15:15:40 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] arm: dma mapping: export arm iommu functions
References: <1356592458-11077-1-git-send-email-prathyush.k@samsung.com>
In-reply-to: <1356592458-11077-1-git-send-email-prathyush.k@samsung.com>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prathyush K <prathyush.k@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, prathyush@chromium.org

Hello,

On 12/27/2012 8:14 AM, Prathyush K wrote:
> This patch adds EXPORT_SYMBOL calls to the three arm iommu
> functions - arm_iommu_create_mapping, arm_iommu_free_mapping
> and arm_iommu_attach_device. These functions can now be called
> from dynamic modules.

Could You describe a bit more why those functions might be needed by 
dynamic modules?

> Signed-off-by: Prathyush K <prathyush.k@samsung.com>
> ---
>   arch/arm/mm/dma-mapping.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 6b2fb87..c0f0f43 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1797,6 +1797,7 @@ err2:
>   err:
>   	return ERR_PTR(err);
>   }
> +EXPORT_SYMBOL(arm_iommu_create_mapping);

EXPORT_SYMOBL_GPL() ?

>   static void release_iommu_mapping(struct kref *kref)
>   {
> @@ -1813,6 +1814,7 @@ void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping)
>   	if (mapping)
>   		kref_put(&mapping->kref, release_iommu_mapping);
>   }
> +EXPORT_SYMBOL(arm_iommu_release_mapping);
>   
>   /**
>    * arm_iommu_attach_device
> @@ -1841,5 +1843,6 @@ int arm_iommu_attach_device(struct device *dev,
>   	pr_debug("Attached IOMMU controller to %s device.\n", dev_name(dev));
>   	return 0;
>   }
> +EXPORT_SYMBOL(arm_iommu_attach_device);
>   
>   #endif

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
