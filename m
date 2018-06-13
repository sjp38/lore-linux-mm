Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A37136B0003
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 09:39:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f9-v6so1577780wmc.7
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 06:39:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a40-v6si1350033edf.324.2018.06.13.06.39.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jun 2018 06:39:16 -0700 (PDT)
Date: Wed, 13 Jun 2018 15:39:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: cma: honor __GFP_ZERO flag in cma_alloc()
Message-ID: <20180613133913.GD20315@dhcp22.suse.cz>
References: <CGME20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2@eucas1p2.samsung.com>
 <20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2~3rI_9nj8b0455904559eucas1p2C@eucas1p2.samsung.com>
 <20180613122359.GA8695@bombadil.infradead.org>
 <20180613124001eucas1p2422f7916367ce19fecd40d6131990383~3uKFrT3ML1977219772eucas1p2G@eucas1p2.samsung.com>
 <20180613125546.GB32016@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180613125546.GB32016@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed 13-06-18 05:55:46, Christoph Hellwig wrote:
> On Wed, Jun 13, 2018 at 02:40:00PM +0200, Marek Szyprowski wrote:
> > It is not only the matter of the spinlocks. GFP_ATOMIC is not supported 
> > by the
> > memory compaction code, which is used in alloc_contig_range(). Right, this
> > should be also noted in the documentation.
> 
> Documentation is good, asserts are better.  The code should reject any
> flag not explicitly supported, or even better have its own flags type
> with the few actually supported flags.

Agreed. Is the cma allocator used for anything other than GFP_KERNEL
btw.? If not then, shouldn't we simply drop the gfp argument altogether
rather than give users a false hope for differen gfp modes that are not
really supported and grow broken code?

-- 
Michal Hocko
SUSE Labs
