Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 87B8D6B025B
	for <linux-mm@kvack.org>; Sat, 14 Nov 2015 07:46:09 -0500 (EST)
Received: by lfdo63 with SMTP id o63so65736415lfd.2
        for <linux-mm@kvack.org>; Sat, 14 Nov 2015 04:46:09 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id kk6si18414949lbb.138.2015.11.14.04.46.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Nov 2015 04:46:08 -0800 (PST)
Date: Sat, 14 Nov 2015 15:45:52 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 03/14] net: tcp_memcontrol: properly detect ancestor
 socket pressure
Message-ID: <20151114124552.GI31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1447371693-25143-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 12, 2015 at 06:41:22PM -0500, Johannes Weiner wrote:
> When charging socket memory, the code currently checks only the local
> page counter for excess to determine whether the memcg is under socket
> pressure. But even if the local counter is fine, one of the ancestors
> could have breached its limit, which should also force this child to
> enter socket pressure. This currently doesn't happen.
> 
> Fix this by using page_counter_try_charge() first. If that fails, it
> means that either the local counter or one of the ancestors are in
> excess of their limit, and the child should enter socket pressure.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

For the record: it was broken by commit 3e32cb2e0a12 ("mm: memcontrol:
lockless page counters").

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
