Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 754716B025E
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 16:07:25 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id o2so34118427wje.5
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 13:07:25 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ma6si1902635wjb.88.2016.12.01.13.07.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 13:07:24 -0800 (PST)
Date: Thu, 1 Dec 2016 16:07:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr in count_shadow_nodes
Message-ID: <20161201210715.GA21302@cmpxchg.org>
References: <20161201132156.21450-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161201132156.21450-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Marek =?iso-8859-1?Q?Marczykowski-G=F3recki?= <marmarek@mimuw.edu.pl>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 01, 2016 at 02:21:56PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 0a6b76dd23fa ("mm: workingset: make shadow node shrinker memcg aware")
> has made the workingset shadow nodes shrinker memcg aware. The
> implementation is not correct though because memcg_kmem_enabled() might
> become true while we are doing a global reclaim when the sc->memcg might
> be NULL which is exactly what Marek has seen:

[...]

> This patch fixes the issue by checking sc->memcg rather than memcg_kmem_enabled()
> which is sufficient because shrink_slab makes sure that only memcg aware shrinkers
> will get non-NULL memcgs and only if memcg_kmem_enabled is true.
> 
> Fixes: 0a6b76dd23fa ("mm: workingset: make shadow node shrinker memcg aware")
> Reported-and-tested-by: Marek Marczykowski-Gorecki <marmarek@mimuw.edu.pl>
> Cc: stable@vger.kernel.org # 4.6+
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks Michal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
