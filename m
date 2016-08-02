Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 213F86B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 11:51:24 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k135so97169515lfb.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 08:51:24 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id v10si22078595wmf.49.2016.08.02.08.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 08:51:23 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o80so31619243wme.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 08:51:22 -0700 (PDT)
Date: Tue, 2 Aug 2016 17:51:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm: memcontrol: add sanity checks for memcg->id.ref
 on get/put
Message-ID: <20160802155120.GA28900@dhcp22.suse.cz>
References: <01cbe4d1a9fd9bbd42c95e91694d8ed9c9fc2208.1470057819.git.vdavydov@virtuozzo.com>
 <ad702144f24374cbfb3a35b71658a0ae24ba7d84.1470057819.git.vdavydov@virtuozzo.com>
 <20160802124503.GK12403@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160802124503.GK12403@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 02-08-16 14:45:03, Michal Hocko wrote:
> On Mon 01-08-16 16:26:26, Vladimir Davydov wrote:
> [...]
> >  static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
> >  {
> > -	while (!atomic_inc_not_zero(&memcg->id.ref))
> > +	while (!atomic_inc_not_zero(&memcg->id.ref)) {
> > +		VM_BUG_ON(mem_cgroup_is_root(memcg));
> >  		memcg = parent_mem_cgroup(memcg);
> > +	}
> 
> why is this BUG_ON ok? What if the root.use_hierarchy=true?

Scratch that. I got it. root will never get its count down to 0. Sorry
about the noise.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
