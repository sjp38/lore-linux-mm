Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 56A406B026F
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 11:01:25 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so103924301pab.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 08:01:25 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id xi10si28167820pab.18.2015.11.13.08.01.24
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 08:01:24 -0800 (PST)
Date: Fri, 13 Nov 2015 11:01:22 -0500 (EST)
Message-Id: <20151113.110122.2158673468450208508.davem@davemloft.net>
Subject: Re: [PATCH 05/14] net: tcp_memcontrol: protect all tcp_memcontrol
 calls by jump-label
From: David Miller <davem@davemloft.net>
In-Reply-To: <1447371693-25143-6-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
	<1447371693-25143-6-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, mhocko@suse.cz, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Thu, 12 Nov 2015 18:41:24 -0500

> Move the jump-label from sock_update_memcg() and sock_release_memcg()
> to the callsite, and so eliminate those function calls when socket
> accounting is not enabled.
> 
> This also eliminates the need for dummy functions because the calls
> will be optimized away if the Kconfig options are not enabled.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
