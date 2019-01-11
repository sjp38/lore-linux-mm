Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Fri, 11 Jan 2019 20:11:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: swap: use mem_cgroup_is_root() instead of
 deferencing css->parent
Message-ID: <20190111191108.GK14956@dhcp22.suse.cz>
References: <1547232913-118148-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1547232913-118148-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ying.huang@intel.com, tim.c.chen@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat 12-01-19 02:55:13, Yang Shi wrote:
> mem_cgroup_is_root() is preferred API to check if memcg is root or not.
> Use it instead of deferencing css->parent.
> 
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Tim Chen <tim.c.chen@intel.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Yes, this is more readable.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/swap.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index a8f6d5d..8739063 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -623,7 +623,7 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
>  		return vm_swappiness;
>  
>  	/* root ? */
> -	if (mem_cgroup_disabled() || !memcg->css.parent)
> +	if (mem_cgroup_disabled() || mem_cgroup_is_root(memcg))
>  		return vm_swappiness;
>  
>  	return memcg->swappiness;
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs
