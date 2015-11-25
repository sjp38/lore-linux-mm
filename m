Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9F16B0257
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:29:06 -0500 (EST)
Received: by padhx2 with SMTP id hx2so61975906pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:29:05 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id q2si35177218pfi.136.2015.11.25.08.29.04
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 08:29:05 -0800 (PST)
Date: Wed, 25 Nov 2015 11:29:02 -0500 (EST)
Message-Id: <20151125.112902.963518845629277747.davem@davemloft.net>
Subject: Re: [PATCH 09/13] mm: memcontrol: generalize the socket accounting
 jump label
From: David Miller <davem@davemloft.net>
In-Reply-To: <1448401925-22501-10-git-send-email-hannes@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
	<1448401925-22501-10-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.cz, tj@kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 24 Nov 2015 16:52:01 -0500

> The unified hierarchy memory controller is going to use this jump
> label as well to control the networking callbacks. Move it to the
> memory controller code and give it a more generic name.
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
