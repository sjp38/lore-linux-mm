Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 43C8A6B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 07:15:19 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w191so615414wme.8
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 04:15:19 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d31si920988edc.404.2017.11.15.04.15.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 Nov 2017 04:15:17 -0800 (PST)
Date: Wed, 15 Nov 2017 07:15:08 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: hugetlbfs basic usage accounting
Message-ID: <20171115121508.GA2501@cmpxchg.org>
References: <20171114172429.8916-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171114172429.8916-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

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

I'm not really buying this argument.

Hugetlb setups tend to be static configurations that require intimate
coordination between booting the kernel with a hugetlb reservation and
precisely setting up the application(s).

In the few cases where you need introspection, you can check the the
HugetlbPages entry in /proc/<pid>/status. The minor convenience
provided by adding an aggregate cgroup counter IMO doesn't outweigh
the weirdness of listing a type of resource in memory.stat that isn't
otherwise acknowledged or controllable as memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
