Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1A66B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 07:45:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 62so12739192pfw.21
        for <linux-mm@kvack.org>; Fri, 04 May 2018 04:45:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n23-v6si13208511pgc.359.2018.05.04.04.45.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 May 2018 04:45:25 -0700 (PDT)
Date: Fri, 4 May 2018 13:45:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm, vmpressure: use kstrndup instead of
 kmalloc+strncpy
Message-ID: <20180504114520.GP4535@dhcp22.suse.cz>
References: <20180503201807.24941-1-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180503201807.24941-1-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu 03-05-18 23:18:07, Andy Shevchenko wrote:
> Using kstrndup() simplifies the code.

if for nothing else then the len+1 being handled by kstrndup is an
improvement.

> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmpressure.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 85350ce2d25d..7142207224d3 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -390,12 +390,11 @@ int vmpressure_register_event(struct mem_cgroup *memcg,
>  	char *token;
>  	int ret = 0;
>  
> -	spec_orig = spec = kzalloc(MAX_VMPRESSURE_ARGS_LEN + 1, GFP_KERNEL);
> +	spec_orig = spec = kstrndup(args, MAX_VMPRESSURE_ARGS_LEN, GFP_KERNEL);
>  	if (!spec) {
>  		ret = -ENOMEM;
>  		goto out;
>  	}
> -	strncpy(spec, args, MAX_VMPRESSURE_ARGS_LEN);
>  
>  	/* Find required level */
>  	token = strsep(&spec, ",");
> -- 
> 2.17.0

-- 
Michal Hocko
SUSE Labs
