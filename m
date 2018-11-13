Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7266C6B0005
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:13:22 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so7402397pgi.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:13:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w22-v6si19524744plp.110.2018.11.12.22.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 22:13:21 -0800 (PST)
Date: Mon, 12 Nov 2018 22:13:17 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 1/9] dmapool: fix boundary comparison
Message-ID: <20181113061317.GL21824@bombadil.infradead.org>
References: <acce3a38-9930-349d-5299-95d2aa5c47e4@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <acce3a38-9930-349d-5299-95d2aa5c47e4@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, linux-mm@kvack.org, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

On Mon, Nov 12, 2018 at 10:41:34AM -0500, Tony Battersby wrote:
> Fixes: e34f44b3517f ("pool: Improve memory usage for devices which can't cross boundaries")
> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>

Acked-by: Matthew Wilcox <willy@infradead.org>
