Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C20678E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 10:26:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v14-v6so2001242edq.10
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 07:26:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s3-v6si2114725edr.14.2018.09.24.07.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 07:26:10 -0700 (PDT)
Date: Mon, 24 Sep 2018 16:26:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/2] mm/page_alloc: Add KBUILD_MODNAME
Message-ID: <20180924142609.GD18685@dhcp22.suse.cz>
References: <1537628013-243902-1-git-send-email-zhe.he@windriver.com>
 <1537628013-243902-2-git-send-email-zhe.he@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1537628013-243902-2-git-send-email-zhe.he@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhe.he@windriver.com
Cc: akpm@linux-foundation.org, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, osalvador@suse.de, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 22-09-18 22:53:33, zhe.he@windriver.com wrote:
> From: He Zhe <zhe.he@windriver.com>
> 
> Add KBUILD_MODNAME to make prints more clear.

Please be more explicit. Examples of before and after would be really
helpful.

> Signed-off-by: He Zhe <zhe.he@windriver.com>
> Cc: akpm@linux-foundation.org
> Cc: mhocko@suse.com
> Cc: vbabka@suse.cz
> Cc: pasha.tatashin@oracle.com
> Cc: mgorman@techsingularity.net
> Cc: aaron.lu@intel.com
> Cc: osalvador@suse.de
> Cc: iamjoonsoo.kim@lge.com
> ---
> v2:
> Split the addition of KBUILD_MODNAME out
> 
>  mm/page_alloc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f34cae1..ead9556 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -14,6 +14,8 @@
>   *          (lots of bits borrowed from Ingo Molnar & Andrew Morton)
>   */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/stddef.h>
>  #include <linux/mm.h>
>  #include <linux/swap.h>
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
