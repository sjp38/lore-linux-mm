Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id ADF676B0002
	for <linux-mm@kvack.org>; Mon, 27 May 2013 11:46:40 -0400 (EDT)
Date: Mon, 27 May 2013 17:46:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH][trivial] memcg: Kconfig info update
Message-ID: <20130527154638.GK27274@dhcp22.suse.cz>
References: <1369668984-2787-1-git-send-email-dserrg@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369668984-2787-1-git-send-email-dserrg@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Dyasly <dserrg@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

CCing Andrew

On Mon 27-05-13 19:36:24, Sergey Dyasly wrote:
> Now there are only 2 members in struct page_cgroup.
> Update config MEMCG description accordingly.
> 
> Signed-off-by: Sergey Dyasly <dserrg@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  init/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index 9d3a788..16d1502 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -876,7 +876,7 @@ config MEMCG
>  
>  	  Note that setting this option increases fixed memory overhead
>  	  associated with each page of memory in the system. By this,
> -	  20(40)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
> +	  8(16)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
>  	  usage tracking struct at boot. Total amount of this is printed out
>  	  at boot.
>  
> -- 
> 1.8.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
