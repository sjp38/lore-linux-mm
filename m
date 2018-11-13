Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2536B0276
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:27:24 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id w19-v6so8840473plq.1
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:27:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n8-v6si7084490plp.183.2018.11.12.22.27.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 22:27:23 -0800 (PST)
Date: Mon, 12 Nov 2018 22:27:20 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 7/9] dmapool: cleanup integer types
Message-ID: <20181113062720.GR21824@bombadil.infradead.org>
References: <39edbec6-9c58-e6f0-61ab-02cb94ab4146@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39edbec6-9c58-e6f0-61ab-02cb94ab4146@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org

On Mon, Nov 12, 2018 at 10:45:21AM -0500, Tony Battersby wrote:
> To represent the size of a single allocation, dmapool currently uses
> 'unsigned int' in some places and 'size_t' in other places.  Standardize
> on 'unsigned int' to reduce overhead, but use 'size_t' when counting all
> the blocks in the entire pool.
> 
> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>

Acked-by: Matthew Wilcox <willy@infradead.org>
