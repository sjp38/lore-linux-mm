Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 98A416B038A
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 02:34:52 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 1so82942839pgz.5
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 23:34:52 -0800 (PST)
Received: from out0-143.mail.aliyun.com (out0-143.mail.aliyun.com. [140.205.0.143])
        by mx.google.com with ESMTP id q1si6745427plb.117.2017.03.01.23.34.51
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 23:34:51 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org> <1488436765-32350-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1488436765-32350-4-git-send-email-minchan@kernel.org>
Subject: Re: [RFC 03/11] mm: remove SWAP_DIRTY in ttu
Date: Thu, 02 Mar 2017 15:34:45 +0800
Message-ID: <079901d29327$77698f60$663cae20$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Michal Hocko' <mhocko@suse.com>, 'Shaohua Li' <shli@kernel.org>


On March 02, 2017 2:39 PM Minchan Kim wrote: 
> @@ -1424,7 +1424,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			} else if (!PageSwapBacked(page)) {
>  				/* dirty MADV_FREE page */

Nit: enrich the comment please.
>  				set_pte_at(mm, address, pvmw.pte, pteval);
> -				ret = SWAP_DIRTY;
> +				SetPageSwapBacked(page);
> +				ret = SWAP_FAIL;
>  				page_vma_mapped_walk_done(&pvmw);
>  				break;
>  			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
