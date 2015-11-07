Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0755E82F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 22:45:45 -0500 (EST)
Received: by padhx2 with SMTP id hx2so133002074pad.1
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 19:45:44 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id fd5si4662225pac.167.2015.11.06.19.45.43
        for <linux-mm@kvack.org>;
        Fri, 06 Nov 2015 19:45:43 -0800 (PST)
Date: Fri, 06 Nov 2015 22:45:41 -0500 (EST)
Message-Id: <20151106.224541.1640743718816725953.davem@davemloft.net>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151106164657.GL4390@dhcp22.suse.cz>
References: <20151106105724.GG4390@dhcp22.suse.cz>
	<20151106161953.GA7813@cmpxchg.org>
	<20151106164657.GL4390@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Michal Hocko <mhocko@kernel.org>
Date: Fri, 6 Nov 2015 17:46:57 +0100

> On Fri 06-11-15 11:19:53, Johannes Weiner wrote:
>> You might think sending these emails is helpful, but it really
>> isn't. Not only is it not contributing code, insights, or solutions,
>> you're now actively sabotaging someone else's effort to build something.
> 
> Come on! Are you even serious?

He is, and I agree %100 with him FWIW.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
