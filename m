Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA426B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 05:42:09 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so1764059pdi.33
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 02:42:08 -0800 (PST)
Received: from psmtp.com ([74.125.245.182])
        by mx.google.com with SMTP id do3si5888734pbc.292.2013.11.19.02.42.06
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 02:42:07 -0800 (PST)
Date: Tue, 19 Nov 2013 11:42:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Expose sysctls for enabling slab/file_cache interleaving
Message-ID: <20131119104203.GB18872@dhcp22.suse.cz>
References: <1384822222-28795-1-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384822222-28795-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Mon 18-11-13 16:50:22, Andi Kleen wrote:
[...]
> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index cc1b01c..10966f5 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -72,12 +72,14 @@ extern int cpuset_slab_spread_node(void);
>  
>  static inline int cpuset_do_page_mem_spread(void)
>  {
> -	return current->flags & PF_SPREAD_PAGE;
> +	return (current->flags & PF_SPREAD_PAGE) ||
> +		sysctl_spread_file_cache;
>  }

But this might break applications that explicitly opt out from
spreading.

>  
>  static inline int cpuset_do_slab_mem_spread(void)
>  {
> -	return current->flags & PF_SPREAD_SLAB;
> +	return (current->flags & PF_SPREAD_SLAB) || 
> +		sysctl_spread_slab;
>  }
>  
>  extern int current_cpuset_is_being_rebound(void);
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
