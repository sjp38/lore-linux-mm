Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0F06B0038
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 11:14:03 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so48665415wgy.2
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 08:14:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ls8si13324512wic.111.2015.04.07.08.14.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Apr 2015 08:14:01 -0700 (PDT)
Date: Tue, 7 Apr 2015 17:13:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Documentation/memcg: update memcg/kmem status
Message-ID: <20150407151358.GB8123@dhcp22.suse.cz>
References: <1427898636-4505-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427898636-4505-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>

On Wed 01-04-15 17:30:36, Vladimir Davydov wrote:
> Memcg/kmem reclaim support has been finally merged. Reflect this in the
> documentation.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  Documentation/cgroups/memory.txt |    8 +++-----
>  init/Kconfig                     |    6 ------
>  2 files changed, 3 insertions(+), 11 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index a22df3ad35ff..f456b4315e86 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -275,11 +275,6 @@ When oom event notifier is registered, event will be delivered.
>  
>  2.7 Kernel Memory Extension (CONFIG_MEMCG_KMEM)
>  
> -WARNING: Current implementation lacks reclaim support. That means allocation
> -	 attempts will fail when close to the limit even if there are plenty of
> -	 kmem available for reclaim. That makes this option unusable in real
> -	 life so DO NOT SELECT IT unless for development purposes.
> -
>  With the Kernel memory extension, the Memory Controller is able to limit
>  the amount of kernel memory used by the system. Kernel memory is fundamentally
>  different than user memory, since it can't be swapped out, which makes it
> @@ -345,6 +340,9 @@ set:
>      In this case, the admin could set up K so that the sum of all groups is
>      never greater than the total memory, and freely set U at the cost of his
>      QoS.
> +    WARNING: In the current implementation, memory reclaim will NOT be
> +    triggered for a cgroup when it hits K while staying below U, which makes
> +    this setup impractical.
>  
>      U != 0, K >= U:
>      Since kmem charges will also be fed to the user counter and reclaim will be
> diff --git a/init/Kconfig b/init/Kconfig
> index 7766b500f679..caffca37ccb7 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1059,12 +1059,6 @@ config MEMCG_KMEM
>  	  the kmem extension can use it to guarantee that no group of processes
>  	  will ever exhaust kernel resources alone.
>  
> -	  WARNING: Current implementation lacks reclaim support. That means
> -	  allocation attempts will fail when close to the limit even if there
> -	  are plenty of kmem available for reclaim. That makes this option
> -	  unusable in real life so DO NOT SELECT IT unless for development
> -	  purposes.
> -
>  config CGROUP_HUGETLB
>  	bool "HugeTLB Resource Controller for Control Groups"
>  	depends on HUGETLB_PAGE
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
