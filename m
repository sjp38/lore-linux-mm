Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f43.google.com (mail-qe0-f43.google.com [209.85.128.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0778C6B00C8
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 11:41:31 -0500 (EST)
Received: by mail-qe0-f43.google.com with SMTP id 2so2963925qeb.2
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:41:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e16si8693849qej.91.2013.12.09.08.41.30
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 08:41:31 -0800 (PST)
Date: Mon, 9 Dec 2013 14:41:09 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v2 3/7] mm/mempolicy: correct putback method for isolate
 pages if failed
Message-ID: <20131209164108.GA14363@localhost.localdomain>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-4-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386580248-22431-4-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Dec 09, 2013 at 06:10:44PM +0900, Joonsoo Kim wrote:
> queue_pages_range() isolates hugetlbfs pages and putback_lru_pages() can't
> handle these. We should change it to putback_movable_pages().
> 
> Naoya said that it is worth going into stable, because it can break
> in-use hugepage list.
> 
> Cc: <stable@vger.kernel.org> # 3.12
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index eca4a31..6d04d37 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1318,7 +1318,7 @@ static long do_mbind(unsigned long start, unsigned long len,
>  		if (nr_failed && (flags & MPOL_MF_STRICT))
>  			err = -EIO;
>  	} else
> -		putback_lru_pages(&pagelist);
> +		putback_movable_pages(&pagelist);
>  
>  	up_write(&mm->mmap_sem);
>   mpol_out:

Acked-by: Rafael Aquini <aquini@redhat.com>


> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
