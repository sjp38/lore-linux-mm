Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B465B6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:25:54 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so15102300wmz.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 03:25:54 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ew17si5698946wjd.262.2016.08.19.03.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 03:25:53 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id o80so2872357wme.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 03:25:53 -0700 (PDT)
Date: Fri, 19 Aug 2016 12:25:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] arm64/hugetlb enable gigantic hugepage
Message-ID: <20160819102551.GA32632@dhcp22.suse.cz>
References: <1471521929-9207-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471521929-9207-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie Yisheng <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 18-08-16 20:05:29, Xie Yisheng wrote:
> As we know, arm64 also support gigantic hugepage eg. 1G.

Well, I do not know that. How can I check?

Anyway to the patch
[...]
> index 87e11d8..b4d8048 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1022,7 +1022,8 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>  		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
>  		nr_nodes--)
>  
> -#if (defined(CONFIG_X86_64) || defined(CONFIG_S390)) && \
> +#if (defined(CONFIG_X86_64) || defined(CONFIG_S390) || \
> +	defined(CONFIG_ARM64)) && \
>  	((defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
>  	defined(CONFIG_CMA))

this ifdef is getting pretty unwieldy. For one thing I think that
respective archs should enable ARCH_HAVE_GIGANTIC_PAGES.

>  static void destroy_compound_gigantic_page(struct page *page,
> -- 
> 1.7.12.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
