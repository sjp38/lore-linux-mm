Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1AA6B0253
	for <linux-mm@kvack.org>; Thu,  5 May 2016 04:32:24 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id j8so8406193lfd.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 01:32:24 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id r5si10102280wju.74.2016.05.05.01.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 01:32:22 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w143so2163804wmw.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 01:32:22 -0700 (PDT)
Date: Thu, 5 May 2016 10:32:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Documentation/memcg: remove restriction of setting kmem
 limit
Message-ID: <20160505083221.GD4386@dhcp22.suse.cz>
References: <572B0105.50503@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <572B0105.50503@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>
Cc: corbet@lwn.net, tj@kernel.org, Zefan Li <lizefan@huawei.com>, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu 05-05-16 16:15:01, Qiang Huang wrote:
> We don't have this restriction for a long time, docs should
> be fixed.
> 
> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
> ---
>  Documentation/cgroup-v1/memory.txt | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
> index ff71e16..d45b201 100644
> --- a/Documentation/cgroup-v1/memory.txt
> +++ b/Documentation/cgroup-v1/memory.txt
> @@ -281,11 +281,9 @@ different than user memory, since it can't be swapped out, which makes it
>  possible to DoS the system by consuming too much of this precious resource.
>  
>  Kernel memory won't be accounted at all until limit on a group is set. This
> -allows for existing setups to continue working without disruption.  The limit
> -cannot be set if the cgroup have children, or if there are already tasks in the
> -cgroup. Attempting to set the limit under those conditions will return -EBUSY.
> -When use_hierarchy == 1 and a group is accounted, its children will
> -automatically be accounted regardless of their limit value.
> +allows for existing setups to continue working without disruption. When
> +use_hierarchy == 1 and a group is accounted, its children will automatically
> +be accounted regardless of their limit value.

The restriction is not there anymore because the accounting is enabled
by default even in the cgroup v1 - see b313aeee2509 ("mm: memcontrol:
enable kmem accounting for all cgroups in the legacy hierarchy"). So
this _whole_ paragraph could see some update.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
