Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 91D6F6B0006
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 04:37:06 -0400 (EDT)
Date: Wed, 27 Mar 2013 09:37:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130327083704.GB16579@dhcp22.suse.cz>
References: <20130322080749.GB31457@dhcp22.suse.cz>
 <514C1388.6090909@huawei.com>
 <514C14BF.3050009@parallels.com>
 <20130322093141.GE31457@dhcp22.suse.cz>
 <514EAC41.5050700@huawei.com>
 <20130325090629.GN2154@dhcp22.suse.cz>
 <51515DEE.70105@parallels.com>
 <20130326084348.GJ2295@dhcp22.suse.cz>
 <51516410.2000007@parallels.com>
 <51524849.6090603@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51524849.6090603@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed 27-03-13 09:15:53, Li Zefan wrote:
> > Although correct, it is a bit misleading. It is static in the sense it
> > is held by a static variable. But it is acquired by kmalloc...
> > 
> > In any way, this is a tiny detail.
> > 
> > FWIW, I am fine with the patch you provided:
> > 
> > Acked-by: Glauber Costa <glommer@parallels.com>
> > 
> 
> Michal, could you resend your final patch to Tejun in a new mail thread?
> There are quite a few different patches inlined in this thread.

Done.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
