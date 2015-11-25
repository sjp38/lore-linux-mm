Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A366F6B0256
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:28:44 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so61849054pac.3
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:28:44 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id lp8si2035456pab.188.2015.11.25.08.28.43
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 08:28:43 -0800 (PST)
Date: Wed, 25 Nov 2015 11:28:41 -0500 (EST)
Message-Id: <20151125.112841.913325896219902485.davem@davemloft.net>
Subject: Re: [PATCH 08/13] net: tcp_memcontrol: simplify linkage between
 socket and page counter
From: David Miller <davem@davemloft.net>
In-Reply-To: <1448401925-22501-9-git-send-email-hannes@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
	<1448401925-22501-9-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.cz, tj@kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 24 Nov 2015 16:52:00 -0500

> There won't be any separate counters for socket memory consumed by
> protocols other than TCP in the future. Remove the indirection and
> link sockets directly to their owning memory cgroup.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
