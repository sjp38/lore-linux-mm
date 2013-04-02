Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 63B356B0006
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 04:43:07 -0400 (EDT)
Message-ID: <515A9A42.3050908@parallels.com>
Date: Tue, 2 Apr 2013 12:43:46 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: don't do cleanup manually if mem_cgroup_css_online()
 fails
References: <515A8A40.6020406@huawei.com>
In-Reply-To: <515A8A40.6020406@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On 04/02/2013 11:35 AM, Li Zefan wrote:
> If memcg_init_kmem() returns -errno when a memcg is being created,
> mem_cgroup_css_online() will decrement memcg and its parent's refcnt,
> (but strangely there's no mem_cgroup_put() for mem_cgroup_get() called
> in memcg_propagate_kmem()).
> 
> But then cgroup core will call mem_cgroup_css_free() to do cleanup...
> 

Not a kmemcg bug, but a real bug. Tested by forcing an ENOMEM condition
to happen manually, and Li patch fixes it.
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Acked-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
