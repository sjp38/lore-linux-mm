Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 797AF6B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 03:43:14 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so16930292pab.16
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 00:43:14 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rm3si2599514pbc.142.2014.12.29.00.43.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Dec 2014 00:43:13 -0800 (PST)
Date: Mon, 29 Dec 2014 11:42:59 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch] mm: memcontrol: switch soft limit default back to
 infinity
Message-ID: <20141229084259.GA9984@esperanza>
References: <1419792468-9278-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1419792468-9278-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Dec 28, 2014 at 01:47:48PM -0500, Johannes Weiner wrote:
> 3e32cb2e0a12 ("mm: memcontrol: lockless page counters") accidentally
> switched the soft limit default from infinity to zero, which turns all
> memcgs with even a single page into soft limit excessors and engages
> soft limit reclaim on all of them during global memory pressure.  This
> makes global reclaim generally more aggressive, but also inverts the
> meaning of existing soft limit configurations where unset soft limits
> are usually more generous than set ones.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Overlooked that :-/

Acked-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
