Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 730626B0339
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 09:29:14 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so37266808pad.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 06:29:14 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id nz10si22331973pbb.208.2015.10.05.06.29.13
        for <linux-mm@kvack.org>;
        Mon, 05 Oct 2015 06:29:13 -0700 (PDT)
Date: Mon, 05 Oct 2015 06:44:51 -0700 (PDT)
Message-Id: <20151005.064451.2162263446408087981.davem@davemloft.net>
Subject: Re: [PATCH] ovs: do not allocate memory from offline numa node
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151002101822.12499.27658.stgit@buzz>
References: <20151002101822.12499.27658.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khlebnikov@yandex-team.ru
Cc: dev@openvswitch.org, pshelar@nicira.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, vbabka@suse.cz, linux-mm@kvack.org

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 02 Oct 2015 13:18:22 +0300

> When openvswitch tries allocate memory from offline numa node 0:
> stats = kmem_cache_alloc_node(flow_stats_cache, GFP_KERNEL | __GFP_ZERO, 0)
> It catches VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid))
> [ replaced with VM_WARN_ON(!node_online(nid)) recently ] in linux/gfp.h
> This patch disables numa affinity in this case.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Applied, but this should probably use NUMA_NO_NODE unconditionally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
