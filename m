Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9469828E1
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 08:42:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so102878651wmz.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:42:34 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id b70si21235019wmg.18.2016.08.02.05.42.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 05:42:33 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id x83so30511991wma.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:42:33 -0700 (PDT)
Date: Tue, 2 Aug 2016 14:42:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160802124231.GJ12403@dhcp22.suse.cz>
References: <01cbe4d1a9fd9bbd42c95e91694d8ed9c9fc2208.1470057819.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01cbe4d1a9fd9bbd42c95e91694d8ed9c9fc2208.1470057819.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On Mon 01-08-16 16:26:24, Vladimir Davydov wrote:
[...]
> +static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
> +{
> +	while (!atomic_inc_not_zero(&memcg->id.ref))
> +		memcg = parent_mem_cgroup(memcg);
> +	return memcg;
> +}

Does this actually work properly? Say we have root -> A so parent is
NULL if root (use_hierarchy == false).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
