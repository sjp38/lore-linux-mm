Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 353136B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 14:12:12 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so614734719pfb.6
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 11:12:12 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id o32si22361494pld.152.2016.12.07.11.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 11:12:10 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id p66so24305171pga.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 11:12:10 -0800 (PST)
Message-ID: <1481137869.4930.62.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Dec 2016 11:11:09 -0800
In-Reply-To: <1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
	 <1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, 2016-12-07 at 11:00 -0800, Eric Dumazet wrote:

>  
> So far, I believe net/unix/af_unix.c uses PAGE_ALLOC_COSTLY_ORDER as
> max_order, but UDP does not do that yet.

For af_unix, it happened in
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=28d6427109d13b0f447cba5761f88d3548e83605

This came to fix a regression, since we had a gigantic slab allocation
in af_unix before 

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=eb6a24816b247c0be6b2e97e68933072874bbe54



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
