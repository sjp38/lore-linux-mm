Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF013830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:55:27 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k135so98590854lfb.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 06:55:27 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cl3si12093725wjb.152.2016.08.29.06.55.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 06:55:26 -0700 (PDT)
Date: Mon, 29 Aug 2016 09:51:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: memcontrol: avoid unused function warning
Message-ID: <20160829135142.GA2172@cmpxchg.org>
References: <20160824113733.2776701-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160824113733.2776701-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 24, 2016 at 12:23:00PM +0200, Arnd Bergmann wrote:
> A bugfix in v4.8-rc2 introduced a harmless warning when CONFIG_MEMCG_SWAP
> is disabled but CONFIG_MEMCG is enabled:
> 
> mm/memcontrol.c:4085:27: error: 'mem_cgroup_id_get_online' defined but not used [-Werror=unused-function]
>  static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
> 
> This moves the function inside of the #ifdef block that hides the
> calling function, to avoid the warning.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 1f47b61fb407 ("mm: memcontrol: fix swap counter leak on swapout from offline cgroup")
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
