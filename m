Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EECAC6B000A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:14:10 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i22-v6so8697706pfj.1
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:14:10 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f5si19675083pgr.411.2018.11.12.22.14.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 22:14:09 -0800 (PST)
Date: Mon, 12 Nov 2018 22:14:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 2/9] dmapool: remove checks for dev == NULL
Message-ID: <20181113061407.GM21824@bombadil.infradead.org>
References: <df529b6e-6744-b1af-01ce-a1b691fbcf0d@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <df529b6e-6744-b1af-01ce-a1b691fbcf0d@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

On Mon, Nov 12, 2018 at 10:42:12AM -0500, Tony Battersby wrote:
> dmapool originally tried to support pools without a device because
> dma_alloc_coherent() supports allocations without a device.  But nobody
> ended up using dma pools without a device, so the current checks in
> dmapool.c for pool->dev == NULL are both insufficient and causing bloat.
> Remove them.
> 
> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>

Acked-by: Matthew Wilcox <willy@infradead.org>
