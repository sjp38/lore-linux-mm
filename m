Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3691E6B026D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 11:00:32 -0500 (EST)
Received: by pasz6 with SMTP id z6so107297687pas.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 08:00:32 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id uq3si28162131pac.225.2015.11.13.08.00.28
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 08:00:28 -0800 (PST)
Date: Fri, 13 Nov 2015 11:00:26 -0500 (EST)
Message-Id: <20151113.110026.2097026445648423318.davem@davemloft.net>
Subject: Re: [PATCH 04/14] net: tcp_memcontrol: remove bogus hierarchy
 pressure propagation
From: David Miller <davem@davemloft.net>
In-Reply-To: <1447371693-25143-5-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
	<1447371693-25143-5-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, mhocko@suse.cz, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Thu, 12 Nov 2015 18:41:23 -0500

> When a cgroup currently breaches its socket memory limit, it enters
> memory pressure mode for itself and its *ancestors*. This throttles
> transmission in unrelated sibling and cousin subtrees that have
> nothing to do with the breached limit.
> 
> On the contrary, breaching a limit should make that group and its
> *children* enter memory pressure mode. But this happens already,
> albeit lazily: if an ancestor limit is breached, siblings will enter
> memory pressure on their own once the next packet arrives for them.
> 
> So no additional hierarchy code is needed. Remove the bogus stuff.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
