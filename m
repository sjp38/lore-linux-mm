Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6ACE6B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 05:18:49 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n6so22595438qtn.2
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 02:18:49 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0091.outbound.protection.outlook.com. [104.47.1.91])
        by mx.google.com with ESMTPS id x32si5697039qta.101.2016.08.24.02.18.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Aug 2016 02:18:48 -0700 (PDT)
Date: Wed, 24 Aug 2016 12:18:39 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: avoid unused function warning
Message-ID: <20160824091839.GE1863@esperanza>
References: <20160824082301.632345-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160824082301.632345-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 24, 2016 at 10:22:43AM +0200, Arnd Bergmann wrote:
> A bugfix in v4.8-rc2 introduced a harmless warning when CONFIG_MEMCG_SWAP
> is disabled but CONFIG_MEMCG is enabled:
> 
> mm/memcontrol.c:4085:27: error: 'mem_cgroup_id_get_online' defined but not used [-Werror=unused-function]
>  static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
> 
> This adds an extra #ifdef that matches the one around the caller to
> avoid the warning.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 1f47b61fb407 ("mm: memcontrol: fix swap counter leak on swapout from offline cgroup")

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
