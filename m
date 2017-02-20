Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 75F006B0038
	for <linux-mm@kvack.org>; Sun, 19 Feb 2017 22:30:42 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 1so59182149pgz.5
        for <linux-mm@kvack.org>; Sun, 19 Feb 2017 19:30:42 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id l127si17180984pga.348.2017.02.19.19.30.39
        for <linux-mm@kvack.org>;
        Sun, 19 Feb 2017 19:30:41 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1487498395-9544-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1487498395-9544-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/thp/autonuma: Use TNF flag instead of vm fault.
Date: Mon, 20 Feb 2017 11:30:26 +0800
Message-ID: <00ec01d28b29$adb7ce70$09276b50$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Aneesh Kumar K.V'" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, 'Rik van Riel' <riel@surriel.com>, 'Mel Gorman' <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


On February 19, 2017 6:00 PM Aneesh Kumar K.V wrote: 
> 
> We are using wrong flag value in task_numa_falt function. This can result in
> us doing wrong numa fault statistics update, because we update num_pages_migrate
> and numa_fault_locality etc based on the flag argument passed.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Fix: bae473a423 ("mm: introduce fault_env")
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

> ---
>  mm/huge_memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 5f3ad65c85de..8f1d93257fb9 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1333,7 +1333,7 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
> 
>  	if (page_nid != -1)
>  		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR,
> -				vmf->flags);
> +				flags);
> 
>  	return 0;
>  }
> --
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
