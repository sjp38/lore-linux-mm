Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 715A06B0271
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 11:01:40 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so103930614pab.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 08:01:40 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id d6si28195349pbu.80.2015.11.13.08.01.39
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 08:01:39 -0800 (PST)
Date: Fri, 13 Nov 2015 11:01:37 -0500 (EST)
Message-Id: <20151113.110137.1839985112517581850.davem@davemloft.net>
Subject: Re: [PATCH 06/14] net: tcp_memcontrol: remove dead per-memcg count
 of allocated sockets
From: David Miller <davem@davemloft.net>
In-Reply-To: <1447371693-25143-7-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
	<1447371693-25143-7-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, mhocko@suse.cz, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Thu, 12 Nov 2015 18:41:25 -0500

> The number of allocated sockets is used for calculations in the soft
> limit phase, where packets are accepted but the socket is under memory
> pressure. Since there is no soft limit phase in tcp_memcontrol, and
> memory pressure is only entered when packets are already dropped, this
> is actually dead code. Remove it.
> 
> As this is the last user of parent_cg_proto(), remove that too.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
