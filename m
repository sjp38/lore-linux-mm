Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 487FD6B0266
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:20:09 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id p4so7411628pgj.21
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:20:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a6-v6si17713850pgc.578.2018.11.12.22.20.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 22:20:08 -0800 (PST)
Date: Mon, 12 Nov 2018 22:20:05 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 5/9] dmapool: rename fields in dma_page
Message-ID: <20181113062005.GP21824@bombadil.infradead.org>
References: <4ac76051-74fc-0a70-4d17-7618823d24c3@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ac76051-74fc-0a70-4d17-7618823d24c3@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

On Mon, Nov 12, 2018 at 10:44:02AM -0500, Tony Battersby wrote:
> Rename fields in 'struct dma_page' in preparation for moving them into
> 'struct page'.  No functional changes.
> 
> in_use -> dma_in_use
> offset -> dma_free_off
> 
> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>

Acked-by: Matthew Wilcox <willy@infradead.org>
