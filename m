Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5448E6B4690
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:42:55 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id w12so16966467wru.20
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:42:55 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x16si2594671wrn.206.2018.11.26.23.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 23:42:53 -0800 (PST)
Date: Tue, 27 Nov 2018 08:42:53 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20181127074253.GB30186@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Any comments?  I'd like to at least get the ball moving on the easy
bits.

On Wed, Nov 14, 2018 at 09:22:40AM +0100, Christoph Hellwig wrote:
> Hi all,
> 
> this series switches the powerpc port to use the generic swiotlb and
> noncoherent dma ops, and to use more generic code for the coherent
> direct mapping, as well as removing a lot of dead code.
> 
> As this series is very large and depends on the dma-mapping tree I've
> also published a git tree:
> 
>     git://git.infradead.org/users/hch/misc.git powerpc-dma.4
> 
> Gitweb:
> 
>     http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.4
> 
> Changes since v3:
>  - rebase on the powerpc fixes tree
>  - add a new patch to actually make the baseline amigaone config
>    configure without warnings
>  - only use ZONE_DMA for 64-bit embedded CPUs, on pseries an IOMMU is
>    always present
>  - fix compile in mem.c for one configuration
>  - drop the full npu removal for now, will be resent separately
>  - a few git bisection fixes
> 
> The changes since v1 are to big to list and v2 was not posted in public.
> 
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu
---end quoted text---
