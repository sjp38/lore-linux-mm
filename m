Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB2416B2D68
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:30:43 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o21so2332008edq.4
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:30:43 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l91si2570086ede.307.2018.11.23.04.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 04:30:42 -0800 (PST)
Date: Fri, 23 Nov 2018 13:30:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page
 tables
Message-ID: <20181123123040.GH8625@dhcp22.suse.cz>
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
Cc: Christoph Hellwig <hch@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Levin Alexander <Alexander.Levin@microsoft.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Nicolas Boichat <drinkcat@chromium.org>, Huaisheng Ye <yehs1@lenovo.com>, Tomasz Figa <tfiga@google.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org, David Rientjes <rientjes@google.com>, Matthias Brugger <matthias.bgg@gmail.com>, yingjoe.chen@mediatek.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Fri 23-11-18 13:23:41, Vlastimil Babka wrote:
> On 11/22/18 9:23 AM, Christoph Hellwig wrote:
[...]
> > But I do agree with the sentiment of not wanting to spread GFP_DMA32
> > futher into the slab allocator.
> 
> I don't see a problem with GFP_DMA32 for custom caches. Generic
> kmalloc() would be worse, since it would have to create a new array of
> kmalloc caches. But that's already ruled out due to the alignment.

Yes that makes quite a lot of sense to me. We do not really need a
generic support. Just make sure that if somebody creates a GFP_DMA32
restricted cache then allow allocating restricted memory from that.

Is there any fundamental reason that this wouldn't be possible?
-- 
Michal Hocko
SUSE Labs
