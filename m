Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f180.google.com (mail-yw0-f180.google.com [209.85.161.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9E56E6B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 04:15:29 -0400 (EDT)
Received: by mail-yw0-f180.google.com with SMTP id g3so243389257ywa.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 01:15:29 -0700 (PDT)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id j128si7013430ywd.173.2016.04.04.01.15.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 01:15:28 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm: add is_highmem_addr() helper
References: <1459427384-21374-1-git-send-email-boris.brezillon@free-electrons.com>
 <1459427384-21374-2-git-send-email-boris.brezillon@free-electrons.com>
From: Vignesh R <vigneshr@ti.com>
Message-ID: <57022253.70400@ti.com>
Date: Mon, 4 Apr 2016 13:44:11 +0530
MIME-Version: 1.0
In-Reply-To: <1459427384-21374-2-git-send-email-boris.brezillon@free-electrons.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Brezillon <boris.brezillon@free-electrons.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, linux-mtd@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dave Gordon <david.s.gordon@intel.com>
Cc: Mark Brown <broonie@kernel.org>, linux-spi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Vinod Koul <vinod.koul@intel.com>, Dan Williams <dan.j.williams@intel.com>, dmaengine@vger.kernel.org, Mauro Carvalho Chehab <m.chehab@samsung.com>, Hans Verkuil <hans.verkuil@cisco.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-media@vger.kernel.org, Richard Weinberger <richard@nod.at>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, linux-crypto@vger.kernel.org, linux-mm@kvack.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org

Hi,

On 03/31/2016 05:59 PM, Boris Brezillon wrote:
> Add an helper to check if a virtual address is in the highmem region.
> 
> Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
> ---
>  include/linux/highmem.h | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index bb3f329..13dff37 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -41,6 +41,14 @@ void kmap_flush_unused(void);
>  
>  struct page *kmap_to_page(void *addr);
>  
> +static inline bool is_highmem_addr(const void *x)
> +{
> +	unsigned long vaddr = (unsigned long)x;
> +
> +	return vaddr >=  PKMAP_BASE &&
> +	       vaddr < ((PKMAP_BASE + LAST_PKMAP) * PAGE_SIZE);


Shouldn't this be:
		vaddr < (PKMAP_BASE + (LAST_PKMAP * PAGE_SIZE)) ?

-- 
Regards
Vignesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
