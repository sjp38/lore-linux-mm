Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 60B736B0039
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 14:28:41 -0400 (EDT)
Received: by mail-gg0-f172.google.com with SMTP id n5so1735750ggj.17
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 11:28:40 -0700 (PDT)
Date: Mon, 29 Jul 2013 14:28:35 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 1/8] cgroup: convert cgroup_ida to cgroup_idr
Message-ID: <20130729182835.GD26076@mtj.dyndns.org>
References: <51F614B2.6010503@huawei.com>
 <51F614C4.7060602@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F614C4.7060602@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

Hello,

On Mon, Jul 29, 2013 at 03:07:48PM +0800, Li Zefan wrote:
> @@ -4590,6 +4599,9 @@ static void cgroup_offline_fn(struct work_struct *work)
>  	/* delete this cgroup from parent->children */
>  	list_del_rcu(&cgrp->sibling);
>  
> +	if (cgrp->id)
> +		idr_remove(&cgrp->root->cgroup_idr, cgrp->id);
> +

Yeap, if we're gonna allow lookups, removal should happen here but can
we please add short comment explaining why that is?  Also, do we want
to clear cgrp->id?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
