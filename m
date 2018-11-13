Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24B136B0270
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:25:12 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r13so7398097pgb.7
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:25:12 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h3-v6si19337691pgl.442.2018.11.12.22.25.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 22:25:11 -0800 (PST)
Date: Mon, 12 Nov 2018 22:25:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 6/9] dmapool: improve scalability of dma_pool_free
Message-ID: <20181113062507.GQ21824@bombadil.infradead.org>
References: <4c3c25ab-5793-c394-9fe4-221b81805536@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4c3c25ab-5793-c394-9fe4-221b81805536@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

On Mon, Nov 12, 2018 at 10:44:40AM -0500, Tony Battersby wrote:
> dma_pool_free() scales poorly when the pool contains many pages because
> pool_find_page() does a linear scan of all allocated pages.  Improve its
> scalability by replacing the linear scan with virt_to_page() and storing
> dmapool private data directly in 'struct page', thereby eliminating
> 'struct dma_page'.  In big O notation, this improves the algorithm from
> O(n^2) to O(n) while also reducing memory usage.
> 
> Thanks to Matthew Wilcox for the suggestion to use struct page.
> 
> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>

Acked-by: Matthew Wilcox <willy@infradead.org>
