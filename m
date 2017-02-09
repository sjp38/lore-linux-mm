Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C1FB26B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 14:20:53 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id x4so5465307wme.3
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 11:20:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s26si5555wma.12.2017.02.09.11.20.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 11:20:52 -0800 (PST)
Date: Thu, 9 Feb 2017 20:20:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/8] mm: cma: Export a few symbols
Message-ID: <20170209192046.GB31906@dhcp22.suse.cz>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
 <2dee6c0baaf08e2c7d48ceb7e97e511c914d0f87.1486655917.git-series.maxime.ripard@free-electrons.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2dee6c0baaf08e2c7d48ceb7e97e511c914d0f87.1486655917.git-series.maxime.ripard@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Joonsoo Kim <js1304@gmail.com>, m.szyprowski@samsung.com

[CC CMA people]

On Thu 09-02-17 17:39:17, Maxime Ripard wrote:
> Modules might want to check their CMA pool size and address for debugging
> and / or have additional checks.
> 
> The obvious way to do this would be through dev_get_cma_area and
> cma_get_base and cma_get_size, that are currently not exported, which
> results in a build failure.
> 
> Export them to prevent such a failure.

Who actually uses those exports. None of the follow up patches does
AFAICS.

> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
> ---
>  drivers/base/dma-contiguous.c | 1 +
>  mm/cma.c                      | 2 ++
>  2 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> index e167a1e1bccb..60f5c2591ccd 100644
> --- a/drivers/base/dma-contiguous.c
> +++ b/drivers/base/dma-contiguous.c
> @@ -35,6 +35,7 @@
>  #endif
>  
>  struct cma *dma_contiguous_default_area;
> +EXPORT_SYMBOL(dma_contiguous_default_area);
>  
>  /*
>   * Default global CMA area size can be defined in kernel's .config.
> diff --git a/mm/cma.c b/mm/cma.c
> index c960459eda7e..b50245282a18 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -47,11 +47,13 @@ phys_addr_t cma_get_base(const struct cma *cma)
>  {
>  	return PFN_PHYS(cma->base_pfn);
>  }
> +EXPORT_SYMBOL(cma_get_base);
>  
>  unsigned long cma_get_size(const struct cma *cma)
>  {
>  	return cma->count << PAGE_SHIFT;
>  }
> +EXPORT_SYMBOL(cma_get_size);
>  
>  static unsigned long cma_bitmap_aligned_mask(const struct cma *cma,
>  					     int align_order)
> -- 
> git-series 0.8.11
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
