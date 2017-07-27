Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31BB96B03BD
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:35:30 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z53so34222611wrz.10
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 07:35:30 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l1si11979674ede.402.2017.07.27.07.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Jul 2017 07:35:28 -0700 (PDT)
Date: Thu, 27 Jul 2017 10:35:21 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm, memcg: reset memory.low during memcg offlining
Message-ID: <20170727143521.GB19738@cmpxchg.org>
References: <20170726083017.3yzeucmi7lcj46qd@esperanza>
 <20170727130428.28856-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727130428.28856-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

CC Andrew - can you route these through the -mm tree please?

On Thu, Jul 27, 2017 at 02:04:27PM +0100, Roman Gushchin wrote:
> A removed memory cgroup with a defined memory.low and some belonging
> pagecache has very low chances to be freed.
> 
> If a cgroup has been removed, there is likely no memory pressure inside
> the cgroup, and the pagecache is protected from the external pressure
> by the defined low limit. The cgroup will be freed only after
> the reclaim of all belonging pages. And it will not happen until
> there are any reclaimable memory in the system. That means,
> there is a good chance, that a cold pagecache will reside
> in the memory for an undefined amount of time, wasting
> system resources.
> 
> This problem was fixed earlier by commit fa06235b8eb0
> ("cgroup: reset css on destruction"), but it's not a best way
> to do it, as we can't really reset all limits/counters during
> cgroup offlining.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
