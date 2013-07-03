Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 0042C6B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 11:57:46 -0400 (EDT)
Date: Wed, 3 Jul 2013 15:57:45 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 1/5] mm, page_alloc: support multiple pages
 allocation
In-Reply-To: <1372840460-5571-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <0000013fa540f411-a89dd4a2-0fc9-428d-ad1e-5fa032413911-000000@email.amazonses.com>
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com> <1372840460-5571-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Wed, 3 Jul 2013, Joonsoo Kim wrote:

> @@ -298,13 +298,15 @@ static inline void arch_alloc_page(struct page *page, int order) { }
>
>  struct page *
>  __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> -		       struct zonelist *zonelist, nodemask_t *nodemask);
> +		       struct zonelist *zonelist, nodemask_t *nodemask,
> +		       unsigned long *nr_pages, struct page **pages);
>

Add a separate function for the allocation of multiple pages instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
