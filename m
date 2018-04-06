Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFF46B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 12:34:40 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j47so1069563wre.11
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 09:34:40 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w1si42353edm.96.2018.04.06.09.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 06 Apr 2018 09:34:39 -0700 (PDT)
Date: Fri, 6 Apr 2018 12:36:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH]
 mm-vmscan-dont-mess-with-pgdat-flags-in-memcg-reclaim-v2-fix
Message-ID: <20180406163605.GE20806@cmpxchg.org>
References: <CALvZod7P7cE38fDrWd=0caA2J6ZOmSzEuLGQH9VSaagCbo5O+A@mail.gmail.com>
 <20180406135215.10057-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180406135215.10057-1-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Fri, Apr 06, 2018 at 04:52:15PM +0300, Andrey Ryabinin wrote:
> On 04/06/2018 05:13 AM, Shakeel Butt wrote:
> > Question: Should this 'flags' be per-node? Is it ok for a congested
> > memcg to call wait_iff_congested for all nodes?
> 
> Indeed, congestion state should be pre-node. If memcg on node A is
> congested, there is no point is stalling memcg reclaim from node B.
> 
> Make congestion state per-cgroup-per-node and record it in
> 'struct mem_cgroup_per_node'.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Thanks for fixing this, Andrey. This is great.

For the combined patch and this fix:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
