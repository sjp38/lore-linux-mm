Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E3D976B0269
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 10:59:49 -0500 (EST)
Received: by padhx2 with SMTP id hx2so103780196pad.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 07:59:49 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id dg1si28136404pad.228.2015.11.13.07.59.49
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 07:59:49 -0800 (PST)
Date: Fri, 13 Nov 2015 10:59:47 -0500 (EST)
Message-Id: <20151113.105947.372664007492693548.davem@davemloft.net>
Subject: Re: [PATCH 02/14] mm: vmscan: simplify memcg vs. global shrinker
 invocation
From: David Miller <davem@davemloft.net>
In-Reply-To: <1447371693-25143-3-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
	<1447371693-25143-3-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, mhocko@suse.cz, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Thu, 12 Nov 2015 18:41:21 -0500

> Letting shrink_slab() handle the root_mem_cgroup, and implicitely the
> !CONFIG_MEMCG case, allows shrink_zone() to invoke the shrinkers
> unconditionally from within the memcg iteration loop.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
