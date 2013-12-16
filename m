Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id E442F6B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:55:28 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id c9so3579787qcz.30
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 02:55:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t8si11172174qeu.18.2013.12.16.02.55.27
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 02:55:28 -0800 (PST)
Date: Mon, 16 Dec 2013 08:55:15 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v3 1/6] mm/migrate: add comment about permanent failure
 path
Message-ID: <20131216105514.GA16165@localhost.localdomain>
References: <1386917611-11319-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386917611-11319-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386917611-11319-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, Dec 13, 2013 at 03:53:26PM +0900, Joonsoo Kim wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Let's add a comment about where the failed page goes to, which makes
> code more readable.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 3747fcd..c6ac87a 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1123,7 +1123,12 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  				nr_succeeded++;
>  				break;
>  			default:
> -				/* Permanent failure */
> +				/*
> +				 * Permanent failure (-EBUSY, -ENOSYS, etc.):
> +				 * unlike -EAGAIN case, the failed page is
> +				 * removed from migration page list and not
> +				 * retried in the next outer loop.
> +				 */
>  				nr_failed++;
>  				break;
>  			}

Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
