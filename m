Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 545C16B0010
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:19:21 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id z22-v6so8834182pfi.0
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:19:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k69si19154750pga.176.2018.11.12.22.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 22:19:20 -0800 (PST)
Date: Mon, 12 Nov 2018 22:19:17 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 4/9] dmapool: improve scalability of dma_pool_alloc
Message-ID: <20181113061917.GO21824@bombadil.infradead.org>
References: <e982cd38-a721-bd06-8da8-0d6a0480685c@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e982cd38-a721-bd06-8da8-0d6a0480685c@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

On Mon, Nov 12, 2018 at 10:43:25AM -0500, Tony Battersby wrote:
> dma_pool_alloc() scales poorly when allocating a large number of pages
> because it does a linear scan of all previously-allocated pages before
> allocating a new one.  Improve its scalability by maintaining a separate
> list of pages that have free blocks ready to (re)allocate.  In big O
> notation, this improves the algorithm from O(n^2) to O(n).
> 
> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>

Acked-by: Matthew Wilcox <willy@infradead.org>
