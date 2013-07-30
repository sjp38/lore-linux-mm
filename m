Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id A1A1C6B0038
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 10:22:03 -0400 (EDT)
Received: by mail-qe0-f47.google.com with SMTP id b10so1651784qen.6
        for <linux-mm@kvack.org>; Tue, 30 Jul 2013 07:22:02 -0700 (PDT)
Date: Tue, 30 Jul 2013 10:21:59 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 1/8] cgroup: convert cgroup_ida to cgroup_idr
Message-ID: <20130730142159.GI12016@htj.dyndns.org>
References: <51F614B2.6010503@huawei.com>
 <51F614C4.7060602@huawei.com>
 <20130729182835.GD26076@mtj.dyndns.org>
 <51F7127B.1070107@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F7127B.1070107@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Tue, Jul 30, 2013 at 09:10:19AM +0800, Li Zefan wrote:
> Set cgrp->id to 0? No, 0 is a valid id. The if is here because at first

I don't know.  -1 then?

> I called idr_alloc() very late in cgroup_create(), so cgroup_offline_fn()
> can be called while cgrp->id hasn't been initialized. Now I can remove
> this check.

I'm just a bit apprehensive as IDs will be recycled very fast and
controllers would keep accessing the css and cgroup after offline
until all refs are drained, so it'd be nice if there's some mechanism
to prevent / detect stale ID usages.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
