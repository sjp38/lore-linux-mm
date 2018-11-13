Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4FDB46B0285
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:36:06 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o9so7426198pgv.19
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:36:06 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j61-v6si20884047plb.121.2018.11.12.22.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 22:36:05 -0800 (PST)
Date: Mon, 12 Nov 2018 22:36:01 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 9/9] dmapool: debug: prevent endless loop in case of
 corruption
Message-ID: <20181113063601.GT21824@bombadil.infradead.org>
References: <9e65ec2e-5e22-4f65-7b92-ca2af0c555f3@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e65ec2e-5e22-4f65-7b92-ca2af0c555f3@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

On Mon, Nov 12, 2018 at 10:46:35AM -0500, Tony Battersby wrote:
> Prevent a possible endless loop with DMAPOOL_DEBUG enabled if a buggy
> driver corrupts DMA pool memory.
> 
> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>

I like it!  Also, here you're using blks_per_alloc in a way which isn't
normally in the performance path, but might be with the right config
options.  With that, I withdraw my objection to the previous patch and

Acked-by: Matthew Wilcox <willy@infradead.org>

Andrew, can you funnel these in through your tree?  If you'd rather not,
I don't mind stuffing them into a git tree and asking Linus to pull
for 4.21.
