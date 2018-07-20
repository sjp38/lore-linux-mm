Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1ECDA6B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:32:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12-v6so4262082edi.12
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 02:32:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t48-v6si1649636edb.321.2018.07.20.02.32.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 02:32:48 -0700 (PDT)
Subject: Re: [PATCH v3 1/7] mm, slab: combine kmalloc_caches and
 kmalloc_dma_caches
References: <20180718133620.6205-1-vbabka@suse.cz>
 <20180718133620.6205-2-vbabka@suse.cz>
 <20180719081020.5pl3naynwhgev6rx@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fbd8741b-1d1d-408b-74e0-5d6e87cb1e54@suse.cz>
Date: Fri, 20 Jul 2018 11:30:23 +0200
MIME-Version: 1.0
In-Reply-To: <20180719081020.5pl3naynwhgev6rx@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>

On 07/19/2018 10:10 AM, Mel Gorman wrote:
> On Wed, Jul 18, 2018 at 03:36:14PM +0200, Vlastimil Babka wrote:
>> The kmalloc caches currently mainain separate (optional) array
>> kmalloc_dma_caches for __GFP_DMA allocations. There are tests for __GFP_DMA in
>> the allocation hotpaths. We can avoid the branches by combining kmalloc_caches
>> and kmalloc_dma_caches into a single two-dimensional array where the outer
>> dimension is cache "type". This will also allow to add kmalloc-reclaimable
>> caches as a third type.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> I'm surprised there are so many kmalloc users that require the DMA zone.
> Some of them are certainly bogus such as in drivers for archs that only
> have one zone and is probably a reflection of the confusing naming. The
> audit would be a mess and unrelated to the patch so for this patch;

Yeah, there was a session about that on LSF/MM and Luis was working on
it. One of the motivations was to get rid of the branch, so that's
sidestepped by this patch. I would still like to not have slabinfo full
of empty dma-kmalloc caches though :)

> Acked-by: Mel Gorman <mgorman@techsingularity.net>
> 
