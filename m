Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 735C26B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 16:06:11 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id f8so16906753qta.1
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 13:06:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h2sor13681822qkf.54.2017.11.14.13.06.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 13:06:10 -0800 (PST)
Date: Tue, 14 Nov 2017 13:06:07 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] memcg: hugetlbfs basic usage accounting
Message-ID: <20171114210607.GT983427@devbig577.frc2.facebook.com>
References: <20171114172429.8916-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171114172429.8916-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 14, 2017 at 05:24:29PM +0000, Roman Gushchin wrote:
> This patch implements basic accounting of memory consumption
> by hugetlbfs pages for cgroup v2 memory controller.
> 
> Cgroup v2 memory controller lacks any visibility into the
> hugetlbfs memory consumption. Cgroup v1 implemented a separate
> hugetlbfs controller, which provided such stats, and also
> provided some control abilities. Although porting of the
> hugetlbfs controller to cgroup v2 is arguable a good idea and
> is outside of scope of this patch, it's very useful to have
> basic stats provided by memory.stat.
> 
> As hugetlbfs memory can easily represent a big portion of total
> memory, it's important to understand who (which memcg/container)
> is using it.
> 
> The number is represented in memory.stat as "hugetlb" in bytes and
> is printed unconditionally. Accounting code doesn't depend on
> cgroup v1 hugetlb controller.
> 
> Example:
>   $ cat /sys/fs/cgroup/user.slice/user-0.slice/session-1.scope/memory.stat
>   anon 1634304
>   file 1163264
>   kernel_stack 16384
>   slab 737280
>   sock 0
>   shmem 0
>   file_mapped 32768
>   file_dirty 4096
>   file_writeback 0
>   inactive_anon 0
>   active_anon 1634304
>   inactive_file 65536
>   active_file 1097728
>   unevictable 0
>   slab_reclaimable 282624
>   slab_unreclaimable 454656
>   hugetlb 1073741824
>   pgfault 4580
>   pgmajfault 13
>   ...
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
