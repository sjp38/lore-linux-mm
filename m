Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB1E6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 05:10:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h186so25738759pfg.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 02:10:57 -0700 (PDT)
Received: from mail-pa0-f65.google.com (mail-pa0-f65.google.com. [209.85.220.65])
        by mx.google.com with ESMTPS id w10si31793712pag.138.2016.07.19.02.10.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 02:10:56 -0700 (PDT)
Received: by mail-pa0-f65.google.com with SMTP id cf3so980473pad.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 02:10:56 -0700 (PDT)
Date: Tue, 19 Jul 2016 11:10:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: hugetlb: remove incorrect comment
Message-ID: <20160719091052.GC9490@dhcp22.suse.cz>
References: <1468894098-12099-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468894098-12099-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zhan Chen <zhanc1@andrew.cmu.edu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue 19-07-16 11:08:18, Naoya Horiguchi wrote:
> dequeue_hwpoisoned_huge_page() can be called without page lock hold,
> so let's remove incorrect comment.

Could you explain why the page lock is not really needed, please? Or
what has changed that it is not needed anymore?

Thanks!

> 
> Reported-by: Zhan Chen <zhanc1@andrew.cmu.edu>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/hugetlb.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git v4.7-rc7/mm/hugetlb.c v4.7-rc7_patched/mm/hugetlb.c
> index c1f3c0b..26f735c 100644
> --- v4.7-rc7/mm/hugetlb.c
> +++ v4.7-rc7_patched/mm/hugetlb.c
> @@ -4401,7 +4401,6 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
>  
>  /*
>   * This function is called from memory failure code.
> - * Assume the caller holds page lock of the head page.
>   */
>  int dequeue_hwpoisoned_huge_page(struct page *hpage)
>  {
> -- 
> 2.7.0
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
