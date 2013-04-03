Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 7F6CB6B00BD
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 04:50:59 -0400 (EDT)
Date: Wed, 3 Apr 2013 10:50:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2] memcg: don't do cleanup manually if
 mem_cgroup_css_online() fails
Message-ID: <20130403085056.GD14384@dhcp22.suse.cz>
References: <20130402141646.GQ24345@dhcp22.suse.cz>
 <515AE948.1000704@parallels.com>
 <20130402142825.GA32520@dhcp22.suse.cz>
 <515AEC3A.2030401@parallels.com>
 <20130402150422.GB32520@dhcp22.suse.cz>
 <515BA6C9.2000704@huawei.com>
 <20130403074300.GA14384@dhcp22.suse.cz>
 <515BDEF2.1080900@huawei.com>
 <20130403081843.GC14384@dhcp22.suse.cz>
 <515BEA61.9080100@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515BEA61.9080100@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Wed 03-04-13 16:37:53, Li Zefan wrote:
> >>> But memcg_update_cache_sizes calls memcg_kmem_clear_activated on the
> >>> error path.
> >>>
> >>
> >> But memcg_kmem_mark_dead() checks the ACCOUNT flag not the ACCOUNTED flag.
> >> Am I missing something?
> >>
> > 
> > Dang. You are right! Glauber, is there any reason why
> > memcg_kmem_mark_dead checks only KMEM_ACCOUNTED_ACTIVE rather than
> > KMEM_ACCOUNTED_MASK?
> > 
> > This all is very confusing to say the least.
> > 
> > Anyway, this all means that Li's first patch is correct. I am not sure I
> > like it though. I think that the refcount cleanup should be done as
> > close to where it has been taken as possible otherwise we will end up in
> > this "chase the nasty details" again and again. There are definitely two
> > bugs here. The one introduced by e4715f01 and the other one introduced
> > even earlier (I haven't checked that history yet). I think we should do
> > something like the 2 follow up patches but if you guys think that the smaller
> > patch from Li is more appropriate then I will not block it.
> > 
> 
> Or we can queue my patch for 3.9, and then see if we want to change the
> tear down process, and if yes we make the change for 3.10.

OK, I thought it would be easier but I always end up with something
similar to your patch. So feel free to add my Acked-by and parts of my
changelog that fit (namely obvious bug introduced by e4715f01 and
documentnation of the clean-up path). I have a split up version in case
others like it more - will follow.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
