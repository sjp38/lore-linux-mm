Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id B38369003CE
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 03:23:07 -0400 (EDT)
Received: by wiga1 with SMTP id a1so144513531wig.0
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 00:23:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8si7395147wjx.17.2015.07.02.00.23.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Jul 2015 00:23:05 -0700 (PDT)
Date: Thu, 2 Jul 2015 09:23:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm:Make the function set_recommended_min_free_kbytes
 have a return type of void
Message-ID: <20150702072302.GA12547@dhcp22.suse.cz>
References: <1435772715-9534-1-git-send-email-xerofoify@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435772715-9534-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 01-07-15 13:45:15, Nicholas Krause wrote:
> This makes the function set_recommended_min_free_kbytes have a
> return type of void now due to this particular function never
> needing to signal it's call if it fails due to this function
> always completing successfully without issue.

The changelog is hard to read for me.
"
The function cannot possibly fail so it doesn't make much sense to have
a return value. Make it void.
"
Would sound much easier to parse for me.

I doubt this would help the compiler to generate a better code but in
general it is better to have void return type when there is no failure
possible - which is the case here.

> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/huge_memory.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index c107094..914a72a 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -104,7 +104,7 @@ static struct khugepaged_scan khugepaged_scan = {
>  };
>  
>  
> -static int set_recommended_min_free_kbytes(void)
> +static void set_recommended_min_free_kbytes(void)
>  {
>  	struct zone *zone;
>  	int nr_zones = 0;
> @@ -139,7 +139,6 @@ static int set_recommended_min_free_kbytes(void)
>  		min_free_kbytes = recommended_min;
>  	}
>  	setup_per_zone_wmarks();
> -	return 0;
>  }
>  
>  static int start_stop_khugepaged(void)
> -- 
> 2.1.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
