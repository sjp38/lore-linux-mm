Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 31F2C6B0031
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 10:31:34 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 Jul 2013 00:16:10 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 2ABF73578053
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 00:31:29 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6FEGFPi55640290
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 00:16:15 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6FEVRVS010477
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 00:31:28 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/9] mm, hugetlb: remove redundant list_empty check in gather_surplus_pages()
In-Reply-To: <1373881967-16153-6-git-send-email-iamjoonsoo.kim@lge.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com> <1373881967-16153-6-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 15 Jul 2013 20:01:24 +0530
Message-ID: <87vc4bj3nn.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> If list is empty, list_for_each_entry_safe() doesn't do anything.
> So, this check is redundant. Remove it.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


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

You can now remove '{' 


>  	spin_lock(&hugetlb_lock);
>
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
