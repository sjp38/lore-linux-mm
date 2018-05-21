Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC87B6B0007
	for <linux-mm@kvack.org>; Mon, 21 May 2018 11:25:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 3-v6so11940165wry.0
        for <linux-mm@kvack.org>; Mon, 21 May 2018 08:25:47 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b79-v6si12944886wrd.260.2018.05.21.08.25.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 08:25:46 -0700 (PDT)
Date: Mon, 21 May 2018 17:30:55 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [RFC PATCH v2 05/12] include/linux/dma-mapping: update usage
	of address zone modifiers
Message-ID: <20180521153055.GA18588@lst.de>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com> <1526916033-4877-6-git-send-email-yehs2007@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1526916033-4877-6-git-send-email-yehs2007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng Ye <yehs2007@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@suse.com, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>

On Mon, May 21, 2018 at 11:20:26PM +0800, Huaisheng Ye wrote:
> From: Huaisheng Ye <yehs1@lenovo.com>
> 
> Use __GFP_ZONE_MASK to replace (__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32).
> 
> ___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP
> bitmasks, the bottom three bits of GFP mask is reserved for storing
> encoded zone number.
> __GFP_DMA, __GFP_HIGHMEM and __GFP_DMA32 should not be operated with
>each others by OR.

You have to include me for the whole series, otherwise I have absolutely
no way to properly review your patch.
