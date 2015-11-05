Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id D21AA82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:30:17 -0500 (EST)
Received: by pasz6 with SMTP id z6so95379077pas.2
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:30:17 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id ax2si11169997pbd.123.2015.11.05.08.30.16
        for <linux-mm@kvack.org>;
        Thu, 05 Nov 2015 08:30:17 -0800 (PST)
Date: Thu, 05 Nov 2015 11:30:12 -0500 (EST)
Message-Id: <20151105.113012.433525933573324396.davem@davemloft.net>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151105162803.GD15111@dhcp22.suse.cz>
References: <20151105144002.GB15111@dhcp22.suse.cz>
	<20151105.111609.1695015438589063316.davem@davemloft.net>
	<20151105162803.GD15111@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 5 Nov 2015 17:28:03 +0100

> Yes, that part is clear and Johannes made it clear that the kmem tcp
> part is disabled by default. Or are you considering also all the slab
> usage by the networking code as well?

I'm still thinking about the implications of that aspect, and will
comment when I have something coherent to say about it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
