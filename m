Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 58C816B0027
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 04:04:31 -0400 (EDT)
Message-ID: <515A90ED.7010208@huawei.com>
Date: Tue, 2 Apr 2013 16:03:57 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: don't do cleanup manually if mem_cgroup_css_online()
 fails
References: <515A8A40.6020406@huawei.com>
In-Reply-To: <515A8A40.6020406@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On 2013/4/2 15:35, Li Zefan wrote:
> If memcg_init_kmem() returns -errno when a memcg is being created,
> mem_cgroup_css_online() will decrement memcg and its parent's refcnt,

> (but strangely there's no mem_cgroup_put() for mem_cgroup_get() called
> in memcg_propagate_kmem()).

The comment in memcg_propagate_kmem() suggests it knows mem_cgroup_css_free()
will be called in failure, while mem_cgroup_css_online() doesn't know.

> 
> But then cgroup core will call mem_cgroup_css_free() to do cleanup...
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> ---
>  mm/memcontrol.c | 11 +----------
>  1 file changed, 1 insertion(+), 10 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
