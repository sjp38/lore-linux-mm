Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA736B0258
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:29:40 -0500 (EST)
Received: by padhx2 with SMTP id hx2so61989371pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:29:40 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id 81si35222869pfr.79.2015.11.25.08.29.39
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 08:29:39 -0800 (PST)
Date: Wed, 25 Nov 2015 11:29:37 -0500 (EST)
Message-Id: <20151125.112937.1072774228536687101.davem@davemloft.net>
Subject: Re: [PATCH 11/13] mm: memcontrol: move socket code for unified
 hierarchy accounting
From: David Miller <davem@davemloft.net>
In-Reply-To: <1448401925-22501-12-git-send-email-hannes@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
	<1448401925-22501-12-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.cz, tj@kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 24 Nov 2015 16:52:03 -0500

> The unified hierarchy memory controller will account socket
> memory. Move the infrastructure functions accordingly.
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
