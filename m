Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E57F6B0266
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 11:37:25 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g24-v6so13866032plq.2
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 08:37:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u90-v6si16403848pfk.82.2018.08.01.08.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 Aug 2018 08:37:24 -0700 (PDT)
Date: Wed, 1 Aug 2018 08:37:13 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Question] A novel case happened when using mempool allocate
 memory.
Message-ID: <20180801153713.GA4039@bombadil.infradead.org>
References: <5B61D243.9050608@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5B61D243.9050608@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 01, 2018 at 11:31:15PM +0800, zhong jiang wrote:
> Hi,  Everyone
> 
>  I ran across the following novel case similar to memory leak in linux-4.1 stable when allocating
>  memory object by kmem_cache_alloc.   it rarely can be reproduced.
> 
> I create a specific  mempool with 24k size based on the slab.  it can not be merged with
> other kmem cache.  I  record the allocation and free usage by atomic_add/sub.    After a while,
> I watch the specific slab consume most of total memory.   After halting the code execution.
> The counter of allocation and free is equal.  Therefore,  I am sure that module have released
> all meory resource.  but the statistic of specific slab is very high but stable by checking /proc/slabinfo.

Please post the code.
