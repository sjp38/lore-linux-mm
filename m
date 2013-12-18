Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5D46B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 09:51:14 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id e51so3019192eek.20
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 06:51:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si296567eew.159.2013.12.18.06.51.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 06:51:12 -0800 (PST)
Date: Wed, 18 Dec 2013 15:51:11 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v3
Message-ID: <20131218145111.GA27510@dhcp22.suse.cz>
References: <1387298904-8824-1-git-send-email-mgorman@suse.de>
 <20131217200210.GG21724@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131217200210.GG21724@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 17-12-13 15:02:10, Johannes Weiner wrote:
[...]
> +pagecache_mempolicy_mode:
> +
> +This is available only on NUMA kernels.
> +
> +Per default, the configured memory policy is applicable to anonymous
> +memory, shmem, tmpfs, etc., whereas pagecache is allocated in an
> +interleaving fashion over all allowed nodes (hardbindings and
> +zone_reclaim_mode excluded).
> +
> +The assumption is that, when it comes to pagecache, users generally
> +prefer predictable replacement behavior regardless of NUMA topology
> +and maximizing the cache's effectiveness in reducing IO over memory
> +locality.

Isn't page spreading (PF_SPREAD_PAGE) intended to do the same thing
semantically? The setting is per-cpuset rather than global which makes
it harder to use but essentially it tries to distribute page cache pages
across all the nodes.

This is really getting confusing. We have zone_reclaim_mode to keep
memory local in general, pagecache_mempolicy_mode to keep page cache
local and PF_SPREAD_PAGE to spread the page cache around nodes.

> +
> +This behavior can be changed by enabling pagecache_mempolicy_mode, in
> +which case page cache allocations will be placed according to the
> +configured memory policy (Documentation/vm/numa_memory_policy.txt).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
