Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5076B6B026D
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:05:32 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id d10-v6so524777wrw.6
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:05:32 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 21-v6si1073696wmi.170.2018.07.17.08.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 08:05:30 -0700 (PDT)
Date: Tue, 17 Jul 2018 17:08:03 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/2] mm/cma: remove unsupported gfp_mask parameter from
	cma_alloc()
Message-ID: <20180717150803.GA22408@lst.de>
References: <20180709121956.20200-1-m.szyprowski@samsung.com> <CGME20180709122019eucas1p2340da484acfcc932537e6014f4fd2c29@eucas1p2.samsung.com> <20180709122019eucas1p2340da484acfcc932537e6014f4fd2c29~-sqTPJKij2939229392eucas1p2j@eucas1p2.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709122019eucas1p2340da484acfcc932537e6014f4fd2c29~-sqTPJKij2939229392eucas1p2j@eucas1p2.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Paul Mackerras <paulus@ozlabs.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Chris Zankel <chris@zankel.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Joerg Roedel <joro@8bytes.org>, Sumit Semwal <sumit.semwal@linaro.org>, Robin Murphy <robin.murphy@arm.com>, Laura Abbott <labbott@redhat.com>, linaro-mm-sig@lists.linaro.org

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
