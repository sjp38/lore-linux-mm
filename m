Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D134A6B0259
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:30:38 -0500 (EST)
Received: by padhx2 with SMTP id hx2so62013003pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:30:38 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id fd3si2037533pab.53.2015.11.25.08.30.38
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 08:30:38 -0800 (PST)
Date: Wed, 25 Nov 2015 11:30:35 -0500 (EST)
Message-Id: <20151125.113035.637118798972617751.davem@davemloft.net>
Subject: Re: [PATCH 12/13] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151124215844.GA1373@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
	<20151124215844.GA1373@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.cz, tj@kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 24 Nov 2015 16:58:44 -0500

> Socket memory can be a significant share of overall memory consumed by
> common workloads. In order to provide reasonable resource isolation in
> the unified hierarchy, this type of memory needs to be included in the
> tracking/accounting of a cgroup under active memory resource control.
> 
> Overhead is only incurred when a non-root control group is created AND
> the memory controller is instructed to track and account the memory
> footprint of that group. cgroup.memory=nosocket can be specified on
> the boot commandline to override any runtime configuration and
> forcibly exclude socket memory from active memory resource control.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
