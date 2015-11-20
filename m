Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 19D526B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 04:48:39 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so112029149pac.3
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 01:48:38 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id vq10si18002497pab.74.2015.11.20.01.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 01:48:38 -0800 (PST)
Date: Fri, 20 Nov 2015 12:48:23 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 06/14] net: tcp_memcontrol: remove dead per-memcg count
 of allocated sockets
Message-ID: <20151120094823.GY31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-7-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1447371693-25143-7-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 12, 2015 at 06:41:25PM -0500, Johannes Weiner wrote:
> The number of allocated sockets is used for calculations in the soft
> limit phase, where packets are accepted but the socket is under memory
> pressure. Since there is no soft limit phase in tcp_memcontrol, and
> memory pressure is only entered when packets are already dropped, this
> is actually dead code. Remove it.

Actually, we can get into the soft limit phase due to the global limit
(tcp_memory_pressure is set), but then using per-memcg sockets_allocated
counter is just wrong.

> 
> As this is the last user of parent_cg_proto(), remove that too.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
