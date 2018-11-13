Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85DB46B000A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:15:59 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id s24-v6so8784053plp.12
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:15:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c17si12937204pgl.385.2018.11.12.22.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 22:15:58 -0800 (PST)
Date: Mon, 12 Nov 2018 22:15:55 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 3/9] dmapool: cleanup dma_pool_destroy
Message-ID: <20181113061555.GN21824@bombadil.infradead.org>
References: <2ff327bb-59f7-5105-0bba-72329cb73154@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2ff327bb-59f7-5105-0bba-72329cb73154@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org

On Mon, Nov 12, 2018 at 10:42:48AM -0500, Tony Battersby wrote:
> Remove a small amount of code duplication between dma_pool_destroy() and
> pool_free_page() in preparation for adding more code without having to
> duplicate it.  No functional changes.
> 
> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>

Acked-by: Matthew Wilcox <willy@infradead.org>
