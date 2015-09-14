Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id DF5846B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 16:49:11 -0400 (EDT)
Received: by qkfq186 with SMTP id q186so63700127qkf.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 13:49:11 -0700 (PDT)
Received: from mail-qk0-x235.google.com (mail-qk0-x235.google.com. [2607:f8b0:400d:c09::235])
        by mx.google.com with ESMTPS id c59si13855725qge.28.2015.09.14.13.49.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 13:49:11 -0700 (PDT)
Received: by qkdw123 with SMTP id w123so63739688qkd.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 13:49:10 -0700 (PDT)
Date: Mon, 14 Sep 2015 16:49:07 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/5] cgroup, memcg, cpuset: implement
 cgroup_taskset_for_each_leader()
Message-ID: <20150914204907.GI25369@htj.duckdns.org>
References: <1441998022-12953-1-git-send-email-tj@kernel.org>
 <1441998022-12953-3-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1441998022-12953-3-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 11, 2015 at 03:00:19PM -0400, Tejun Heo wrote:
> It wasn't explicitly documented but, when a process is being migrated,
> cpuset and memcg depend on cgroup_taskset_first() returning the
> threadgroup leader; however, this approach is somewhat ghetto and
> would no longer work for the planned multi-process migration.
> 
> This patch introduces explicit cgroup_taskset_for_each_leader() which
> iterates over only the threadgroup leaders and replaces
> cgroup_taskset_first() usages for accessing the leader with it.
> 
> This prepares both memcg and cpuset for multi-process migration.  This
> patch also updates the documentation for cgroup_taskset_for_each() to
> clarify the iteration rules and removes comments mentioning task
> ordering in tasksets.
> 
> v2: A previous patch which added threadgroup leader test was dropped.
>     Patch updated accordingly.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Acked-by: Zefan Li <lizefan@huawei.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>

Michal, if you're okay with this patch, I'll apply the patchset in
cgroup/for-4.4.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
