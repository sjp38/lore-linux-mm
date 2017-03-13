Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42C9F6B0436
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 02:23:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o126so285359168pfb.2
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 23:23:30 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id r3si17259686plb.271.2017.03.12.23.23.27
        for <linux-mm@kvack.org>;
        Sun, 12 Mar 2017 23:23:29 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1489365353-28205-1-git-send-email-minchan@kernel.org> <1489365353-28205-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1489365353-28205-2-git-send-email-minchan@kernel.org>
Subject: Re: [PATCH v1 01/10] mm: remove unncessary ret in page_referenced
Date: Mon, 13 Mar 2017 14:23:12 +0800
Message-ID: <099101d29bc2$4aef6790$e0ce36b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Michal Hocko' <mhocko@suse.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Anshuman Khandual' <khandual@linux.vnet.ibm.com>


On March 13, 2017 8:36 AM Minchan Kim wrote: 
> 
> Anyone doesn't use ret variable. Remove it.
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


>  mm/rmap.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 7d24bb9..9dbfa6f 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -807,7 +807,6 @@ int page_referenced(struct page *page,
>  		    struct mem_cgroup *memcg,
>  		    unsigned long *vm_flags)
>  {
> -	int ret;
>  	int we_locked = 0;
>  	struct page_referenced_arg pra = {
>  		.mapcount = total_mapcount(page),
> @@ -841,7 +840,7 @@ int page_referenced(struct page *page,
>  		rwc.invalid_vma = invalid_page_referenced_vma;
>  	}
> 
> -	ret = rmap_walk(page, &rwc);
> +	rmap_walk(page, &rwc);
>  	*vm_flags = pra.vm_flags;
> 
>  	if (we_locked)
> --
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
