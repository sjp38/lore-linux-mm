Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0F2D6B000A
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 08:55:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g15-v6so1279894pfh.10
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 05:55:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t190-v6si2442238pgc.445.2018.06.13.05.55.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Jun 2018 05:55:48 -0700 (PDT)
Date: Wed, 13 Jun 2018 05:55:46 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: cma: honor __GFP_ZERO flag in cma_alloc()
Message-ID: <20180613125546.GB32016@infradead.org>
References: <CGME20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2@eucas1p2.samsung.com>
 <20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2~3rI_9nj8b0455904559eucas1p2C@eucas1p2.samsung.com>
 <20180613122359.GA8695@bombadil.infradead.org>
 <20180613124001eucas1p2422f7916367ce19fecd40d6131990383~3uKFrT3ML1977219772eucas1p2G@eucas1p2.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180613124001eucas1p2422f7916367ce19fecd40d6131990383~3uKFrT3ML1977219772eucas1p2G@eucas1p2.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Jun 13, 2018 at 02:40:00PM +0200, Marek Szyprowski wrote:
> It is not only the matter of the spinlocks. GFP_ATOMIC is not supported 
> by the
> memory compaction code, which is used in alloc_contig_range(). Right, this
> should be also noted in the documentation.

Documentation is good, asserts are better.  The code should reject any
flag not explicitly supported, or even better have its own flags type
with the few actually supported flags.
