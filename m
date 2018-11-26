Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D49DE6B4100
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 03:02:31 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v11so20938744ply.4
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 00:02:31 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a17si16742199pfn.213.2018.11.26.00.02.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 26 Nov 2018 00:02:30 -0800 (PST)
Date: Mon, 26 Nov 2018 00:02:13 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page
 tables
Message-ID: <20181126080213.GA17809@infradead.org>
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <0100016737801f14-84f1265d-4577-4dcf-ad57-90dbc8e0a78f-000000@email.amazonses.com>
 <20181121213853.GL3065@bombadil.infradead.org>
 <c5ccde1e-a711-ad33-537c-2d5a0bd9edd4@arm.com>
 <20181122082336.GA2049@infradead.org>
 <555dd63a-0634-6a39-7abc-121e02273cb2@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <555dd63a-0634-6a39-7abc-121e02273cb2@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Levin Alexander <Alexander.Levin@microsoft.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Nicolas Boichat <drinkcat@chromium.org>, Huaisheng Ye <yehs1@lenovo.com>, Tomasz Figa <tfiga@google.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Michal Hocko <mhocko@suse.com>, linux-arm-kernel@lists.infradead.org, David Rientjes <rientjes@google.com>, Matthias Brugger <matthias.bgg@gmail.com>, yingjoe.chen@mediatek.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Nov 23, 2018 at 01:23:41PM +0100, Vlastimil Babka wrote:
> Is this also true for caches created by kmem_cache_create(), that
> debugging options can result in not respecting the alignment passed to
> kmem_cache_create()? That would be rather bad, IMHO.

That's what I understood in the discussion.  If not it would make
our live simpler, but would need to be well document.

Christoph can probably explain the alignment choices in slub.

> 
> > But I do agree with the sentiment of not wanting to spread GFP_DMA32
> > futher into the slab allocator.
> 
> I don't see a problem with GFP_DMA32 for custom caches. Generic
> kmalloc() would be worse, since it would have to create a new array of
> kmalloc caches. But that's already ruled out due to the alignment.

True, purely slab probably isn't too bad.
