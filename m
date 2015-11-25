Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E56686B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:26:42 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so63772467pab.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:26:42 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id d10si34942394pap.237.2015.11.25.08.26.41
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 08:26:42 -0800 (PST)
Date: Wed, 25 Nov 2015 11:26:39 -0500 (EST)
Message-Id: <20151125.112639.2178229649261742673.davem@davemloft.net>
Subject: Re: [PATCH 06/13] net: tcp_memcontrol: simplify the per-memcg
 limit access
From: David Miller <davem@davemloft.net>
In-Reply-To: <1448401925-22501-7-git-send-email-hannes@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
	<1448401925-22501-7-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.cz, tj@kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 24 Nov 2015 16:51:58 -0500

> tcp_memcontrol replicates the global sysctl_mem limit array per
> cgroup, but it only ever sets these entries to the value of the
> memory_allocated page_counter limit. Use the latter directly.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
