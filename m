Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 73BAB6B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 05:38:14 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 89-v6so11895136plc.1
        for <linux-mm@kvack.org>; Tue, 22 May 2018 02:38:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1-v6si16198292plw.519.2018.05.22.02.38.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 May 2018 02:38:13 -0700 (PDT)
Date: Tue, 22 May 2018 02:38:06 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH v2 02/12] arch/x86/kernel/amd_gart_64: update usage
 of address zone modifiers
Message-ID: <20180522093806.GA25671@infradead.org>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <1526916033-4877-3-git-send-email-yehs2007@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1526916033-4877-3-git-send-email-yehs2007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng Ye <yehs2007@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@suse.com, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Robin Murphy <robin.murphy@arm.com>

This code doesn't exist in current mainline.  What kernel version
is your patch against?

On Mon, May 21, 2018 at 11:20:23PM +0800, Huaisheng Ye wrote:
> From: Huaisheng Ye <yehs1@lenovo.com>
> 
> Use __GFP_ZONE_MASK to replace (__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32).
> 
> ___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP
> bitmasks, the bottom three bits of GFP mask is reserved for storing
> encoded zone number.
> __GFP_DMA, __GFP_HIGHMEM and __GFP_DMA32 should not be operated by OR.

If they have already been deleted the identifier should not exist
anymore, so either your patch has issues, or at least the description.
