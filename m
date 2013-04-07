Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 44B976B0006
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 15:51:18 -0400 (EDT)
Received: by mail-ea0-f172.google.com with SMTP id z7so2042031eaf.31
        for <linux-mm@kvack.org>; Sun, 07 Apr 2013 12:51:16 -0700 (PDT)
Date: Sun, 7 Apr 2013 21:51:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 0/7] memcg: make memcg's life cycle the same as
 cgroup
Message-ID: <20130407195112.GA12678@dhcp22.suse.cz>
References: <515BF233.6070308@huawei.com>
 <516131D7.8030004@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <516131D7.8030004@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Sun 07-04-13 16:44:07, Li Zefan wrote:
> Hi,
> 
> I'm rebasing this patchset against latest linux-next, and it conflicts with
> "[PATCH v2] memcg: debugging facility to access dangling memcgs." slightly.
> 
> That is a debugging patch and will never be pushed into mainline, so should I
> still base this patchset on that debugging patch?

Could you split CONFIG_MEMCG_DEBUG_ASYNC_DESTROY changes into a separate
patch so that Andrew could put it on top of the mentioned patch?

> Also that patch needs update (and can be simplified) after this patchset:
> - move memcg_dangling_add() to mem_cgroup_css_offline()
> - remove memcg->memcg_name, and use cgroup_path() in mem_cgroup_dangling_read()?

Every improvement is welcome.

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
