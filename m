Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD9F96B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 09:47:53 -0500 (EST)
Received: by mail-lf0-f51.google.com with SMTP id p203so31126564lfa.0
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 06:47:53 -0800 (PST)
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com. [209.85.215.41])
        by mx.google.com with ESMTPS id 198si4033229lff.81.2015.12.16.06.47.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 06:47:52 -0800 (PST)
Received: by mail-lf0-f41.google.com with SMTP id l133so30629044lfd.2
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 06:47:52 -0800 (PST)
Date: Wed, 16 Dec 2015 15:47:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: make sure isolate_lru_page() is never called for
 tail page
Message-ID: <20151216144749.GB23092@dhcp22.suse.cz>
References: <1450276170-140679-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450276170-140679-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed 16-12-15 16:29:30, Kirill A. Shutemov wrote:
> The VM_BUG_ON_PAGE() would catch such cases if any still exists.

Thanks, this better than a silent breakage.
 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 964390906167..05dd182f04fd 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1436,6 +1436,7 @@ int isolate_lru_page(struct page *page)
>  	int ret = -EBUSY;
>  
>  	VM_BUG_ON_PAGE(!page_count(page), page);
> +	VM_BUG_ON_PAGE(PageTail(page), page);
>  
>  	if (PageLRU(page)) {
>  		struct zone *zone = page_zone(page);
> -- 
> 2.6.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
