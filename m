Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 96B1B6B0010
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 03:45:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id v26-v6so8561634eds.9
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 00:45:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9-v6si1743509edf.112.2018.07.16.00.45.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 00:45:33 -0700 (PDT)
Subject: Re: [PATCH 2/2] dma: remove unsupported gfp_mask parameter from
 dma_alloc_from_contiguous()
References: <20180709121956.20200-1-m.szyprowski@samsung.com>
 <CGME20180709122020eucas1p21a71b092975cb4a3b9954ffc63f699d1@eucas1p2.samsung.com>
 <20180709122020eucas1p21a71b092975cb4a3b9954ffc63f699d1~-sqUFoa-h2939329393eucas1p2Y@eucas1p2.samsung.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c4380664-e9c2-f366-f776-f24af8a42f27@suse.cz>
Date: Mon, 16 Jul 2018 09:45:31 +0200
MIME-Version: 1.0
In-Reply-To: <20180709122020eucas1p21a71b092975cb4a3b9954ffc63f699d1~-sqUFoa-h2939329393eucas1p2Y@eucas1p2.samsung.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Paul Mackerras <paulus@ozlabs.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Chris Zankel <chris@zankel.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Joerg Roedel <joro@8bytes.org>, Sumit Semwal <sumit.semwal@linaro.org>, Robin Murphy <robin.murphy@arm.com>, Laura Abbott <labbott@redhat.com>, linaro-mm-sig@lists.linaro.org

On 07/09/2018 02:19 PM, Marek Szyprowski wrote:
> The CMA memory allocator doesn't support standard gfp flags for memory
> allocation, so there is no point having it as a parameter for
> dma_alloc_from_contiguous() function. Replace it by a boolean no_warn
> argument, which covers all the underlaying cma_alloc() function supports.
> 
> This will help to avoid giving false feeling that this function supports
> standard gfp flags and callers can pass __GFP_ZERO to get zeroed buffer,
> what has already been an issue: see commit dd65a941f6ba ("arm64:
> dma-mapping: clear buffers allocated with FORCE_CONTIGUOUS flag").
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
