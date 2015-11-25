Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 745586B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:29:24 -0500 (EST)
Received: by pacej9 with SMTP id ej9so61866316pac.2
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:29:24 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id h71si35202101pfj.158.2015.11.25.08.29.23
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 08:29:23 -0800 (PST)
Date: Wed, 25 Nov 2015 11:29:21 -0500 (EST)
Message-Id: <20151125.112921.1371682675467323296.davem@davemloft.net>
Subject: Re: [PATCH 10/13] mm: memcontrol: do not account memory+swap on
 unified hierarchy
From: David Miller <davem@davemloft.net>
In-Reply-To: <1448401925-22501-11-git-send-email-hannes@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
	<1448401925-22501-11-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.cz, tj@kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 24 Nov 2015 16:52:02 -0500

> The unified hierarchy memory controller doesn't expose the memory+swap
> counter to userspace, but its accounting is hardcoded in all charge
> paths right now, including the per-cpu charge cache ("the stock").
> 
> To avoid adding yet more pointless memory+swap accounting with the
> socket memory support in unified hierarchy, disable the counter
> altogether when in unified hierarchy mode.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
