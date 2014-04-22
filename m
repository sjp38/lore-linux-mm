Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id E7A9A6B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 05:25:14 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e49so4382318eek.11
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 02:25:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si58891860een.143.2014.04.22.02.25.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 02:25:13 -0700 (PDT)
Date: Tue, 22 Apr 2014 11:25:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Documentation/memcg: warn about incomplete kmemcg state
Message-ID: <20140422092508.GA29311@dhcp22.suse.cz>
References: <1398066420-30707-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398066420-30707-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 21-04-14 11:47:00, Vladimir Davydov wrote:
> Kmemcg is currently under development and lacks some important features.
> In particular, it does not have support of kmem reclaim on memory
> pressure inside cgroup, which practically makes it unusable in real
> life. Let's warn about it in both Kconfig and Documentation to prevent
> complaints arising.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Thanks! This should have been merged log time ago...

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  Documentation/cgroups/memory.txt |    5 +++++
>  init/Kconfig                     |    6 ++++++
>  2 files changed, 11 insertions(+)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 2622115276aa..af3cdfa3c07a 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -270,6 +270,11 @@ When oom event notifier is registered, event will be delivered.
>  
>  2.7 Kernel Memory Extension (CONFIG_MEMCG_KMEM)
>  
> +WARNING: Current implementation lacks reclaim support. That means allocation
> +	 attempts will fail when close to the limit even if there are plenty of
> +	 kmem available for reclaim. That makes this option unusable in real
> +	 life so DO NOT SELECT IT unless for development purposes.
> +
>  With the Kernel memory extension, the Memory Controller is able to limit
>  the amount of kernel memory used by the system. Kernel memory is fundamentally
>  different than user memory, since it can't be swapped out, which makes it
> diff --git a/init/Kconfig b/init/Kconfig
> index 427ba60d638f..4d6e645c8ad4 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -993,6 +993,12 @@ config MEMCG_KMEM
>  	  the kmem extension can use it to guarantee that no group of processes
>  	  will ever exhaust kernel resources alone.
>  
> +	  WARNING: Current implementation lacks reclaim support. That means
> +	  allocation attempts will fail when close to the limit even if there
> +	  are plenty of kmem available for reclaim. That makes this option
> +	  unusable in real life so DO NOT SELECT IT unless for development
> +	  purposes.
> +
>  config CGROUP_HUGETLB
>  	bool "HugeTLB Resource Controller for Control Groups"
>  	depends on RESOURCE_COUNTERS && HUGETLB_PAGE
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
