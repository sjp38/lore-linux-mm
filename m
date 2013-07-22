Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 23D1C6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 10:55:43 -0400 (EDT)
Date: Mon, 22 Jul 2013 16:55:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 5/9] mm, hugetlb: remove redundant list_empty check in
 gather_surplus_pages()
Message-ID: <20130722145541.GG24400@dhcp22.suse.cz>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1373881967-16153-6-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373881967-16153-6-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Mon 15-07-13 18:52:43, Joonsoo Kim wrote:
> If list is empty, list_for_each_entry_safe() doesn't do anything.
> So, this check is redundant. Remove it.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a838e6b..d4a1695 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1019,10 +1019,8 @@ free:
>  	spin_unlock(&hugetlb_lock);
>  
>  	/* Free unnecessary surplus pages to the buddy allocator */
> -	if (!list_empty(&surplus_list)) {
> -		list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
> -			put_page(page);
> -		}
> +	list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
> +		put_page(page);
>  	}
>  	spin_lock(&hugetlb_lock);
>  
> -- 
> 1.7.9.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
