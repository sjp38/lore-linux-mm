Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 1A9A06B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 19:26:16 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so4108202pad.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 16:26:15 -0700 (PDT)
Date: Mon, 29 Oct 2012 16:26:02 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg/cgroup: do not fail fail on pre_destroy callbacks
Message-ID: <20121029232602.GF4066@htj.dyndns.org>
References: <1351251453-6140-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351251453-6140-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@parallels.com>

Hello, Michal.

> Tejun is planning to build on top of that and make some more cleanups
> in the cgroup core (namely get rid of of the whole retry code in
> cgroup_rmdir).

I applied 1-3 to the following branch which is based on top of v3.6.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git cgroup-destroy-updates

I'll follow up with updates to the destroy path which will replace #4.
#5 and #6 should be stackable on top.  So, Andrew, there's likely be a
conflict in the near future.  Just dropping #4-#6 till Michal and I
sort it out should be enough.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
