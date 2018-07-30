Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9EEE76B026E
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:45:02 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id x9-v6so10597396qto.18
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:45:02 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id n33-v6si399293qvg.190.2018.07.30.08.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 Jul 2018 08:45:01 -0700 (PDT)
Date: Mon, 30 Jul 2018 15:45:01 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v3 3/7] mm, slab: allocate off-slab freelists as reclaimable
 when appropriate
In-Reply-To: <20180718133620.6205-4-vbabka@suse.cz>
Message-ID: <01000164ebdd3863-bc2d38db-9d61-442f-a2e4-6196106d5ce4-000000@email.amazonses.com>
References: <20180718133620.6205-1-vbabka@suse.cz> <20180718133620.6205-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On Wed, 18 Jul 2018, Vlastimil Babka wrote:

> In SLAB, OFF_SLAB caches allocate management structures (currently just the
> freelist) from kmalloc caches when placement in a slab page together with
> objects would lead to suboptimal memory usage. For SLAB_RECLAIM_ACCOUNT caches,
> we can allocate the freelists from the newly introduced reclaimable kmalloc
> caches, because shrinking the OFF_SLAB cache will in general result to freeing
> of the freelists as well. This should improve accounting and anti-fragmentation
> a bit.

Acked-by: Christoph Lameter <cl@linux.com>
