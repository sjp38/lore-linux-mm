Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A19A6B0271
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:06:01 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s18-v6so628466wmh.0
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:06:01 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id e1-v6si1222847wrc.392.2018.07.17.08.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 08:05:59 -0700 (PDT)
Date: Tue, 17 Jul 2018 17:08:32 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] dma: remove unsupported gfp_mask parameter from
	dma_alloc_from_contiguous()
Message-ID: <20180717150832.GB22408@lst.de>
References: <20180709121956.20200-1-m.szyprowski@samsung.com> <CGME20180709122020eucas1p21a71b092975cb4a3b9954ffc63f699d1@eucas1p2.samsung.com> <20180709122020eucas1p21a71b092975cb4a3b9954ffc63f699d1~-sqUFoa-h2939329393eucas1p2Y@eucas1p2.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709122020eucas1p21a71b092975cb4a3b9954ffc63f699d1~-sqUFoa-h2939329393eucas1p2Y@eucas1p2.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Paul Mackerras <paulus@ozlabs.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Chris Zankel <chris@zankel.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Joerg Roedel <joro@8bytes.org>, Sumit Semwal <sumit.semwal@linaro.org>, Robin Murphy <robin.murphy@arm.com>, Laura Abbott <labbott@redhat.com>, linaro-mm-sig@lists.linaro.org

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
