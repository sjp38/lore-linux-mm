Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 13DBB6B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 15:50:36 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id fl17so7938248vcb.14
        for <linux-mm@kvack.org>; Mon, 05 Nov 2012 12:50:34 -0800 (PST)
Message-ID: <50982698.7050605@gmail.com>
Date: Mon, 05 Nov 2012 15:50:32 -0500
From: Xi Wang <xi.wang@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix NULL checking in dma_pool_create()
References: <1352097996-25808-1-git-send-email-xi.wang@gmail.com> <20121105123738.0a0490a7.akpm@linux-foundation.org>
In-Reply-To: <20121105123738.0a0490a7.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/5/12 3:37 PM, Andrew Morton wrote:
> 
> Well, the dma_pool_create() kerneldoc does not describe dev==NULL to be
> acceptable usage and given the lack of oops reports, we can assume that
> no code is calling this function with dev==NULL.
> 
> So I think we can just remove the code which handles dev==NULL?

Actually, a quick grep gives the following...

arch/arm/mach-s3c64xx/dma.c:731:	dma_pool = dma_pool_create("DMA-LLI", NULL, sizeof(struct pl080s_lli), 16, 0);
drivers/usb/gadget/amd5536udc.c:3136:	dev->data_requests = dma_pool_create("data_requests", NULL,
drivers/usb/gadget/amd5536udc.c:3148:	dev->stp_requests = dma_pool_create("setup requests", NULL,
drivers/net/wan/ixp4xx_hss.c:973:		if (!(dma_pool = dma_pool_create(DRV_NAME, NULL,
drivers/net/ethernet/xscale/ixp4xx_eth.c:1106:		if (!(dma_pool = dma_pool_create(DRV_NAME, NULL,

- xi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
