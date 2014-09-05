Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 37ABB6B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 09:55:26 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id le20so988414vcb.17
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 06:55:26 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id gr5si4241913pbc.131.2014.09.05.06.55.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Sep 2014 06:55:21 -0700 (PDT)
Date: Fri, 5 Sep 2014 17:55:07 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch] mm: memcontrol: revert use of root_mem_cgroup res_counter
Message-ID: <20140905135507.GE25641@esperanza>
References: <1409921037-21405-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1409921037-21405-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Sep 05, 2014 at 08:43:57AM -0400, Johannes Weiner wrote:
> Dave Hansen reports a massive scalability regression in an uncontained
> page fault benchmark with more than 30 concurrent threads, which he
> bisected down to 05b843012335 ("mm: memcontrol: use root_mem_cgroup
> res_counter") and pin-pointed on res_counter spinlock contention.
> 
> That change relied on the per-cpu charge caches to mostly swallow the
> res_counter costs, but it's apparent that the caches don't scale yet.
> 
> Revert memcg back to bypassing res_counters on the root level in order
> to restore performance for uncontained workloads.
> 
> Reported-by: Dave Hansen <dave@sr71.net>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Tested-by: Dave Hansen <dave.hansen@intel.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>

It's a pity we have to revert this nice cleanup, but seems we can't do
anything better right now. FWIW,

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
