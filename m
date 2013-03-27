Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 58AE96B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 12:15:33 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id gd11so6606279vcb.4
        for <linux-mm@kvack.org>; Wed, 27 Mar 2013 09:15:32 -0700 (PDT)
Date: Wed, 27 Mar 2013 09:15:27 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130327161527.GA7395@htj.dyndns.org>
References: <1364373399-17397-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364373399-17397-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Mar 27, 2013 at 09:36:39AM +0100, Michal Hocko wrote:
> +/*
> + * Called with memcg_cache_mutex held
> + */
>  static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
>  					 struct kmem_cache *s)

Maybe the name could signify it's part of memcg?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
