Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8FDE6B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:49:27 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a64so129198377oii.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 02:49:27 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id n5si12437130ioo.185.2016.06.17.02.49.26
        for <linux-mm@kvack.org>;
        Fri, 17 Jun 2016 02:49:27 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1466155971-6280-1-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1466155971-6280-1-git-send-email-opensource.ganesh@gmail.com>
Subject: Re: [PATCH] mm/compaction: remove local variable is_lru
Date: Fri, 17 Jun 2016 17:49:11 +0800
Message-ID: <056101d1c87d$804381b0$80ca8510$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Ganesh Mahendran' <opensource.ganesh@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mhocko@suse.com, minchan@kernel.org

> 
> local varialbe is_lru was used for tracking non-lru pages(such as
> balloon pages).
> 
> But commit
> 112ea7b668d3 ("mm: migrate: support non-lru movable page migration")
> introduced a common framework for non-lru page migration and moved
> the compound pages check before non-lru movable pages check.
> 
> So there is no need to use local variable is_lru.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/compaction.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index fbb7b38..780be7f 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -724,7 +724,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> 
>  	/* Time to isolate some pages for migration */
>  	for (; low_pfn < end_pfn; low_pfn++) {
> -		bool is_lru;
> 
>  		if (skip_on_failure && low_pfn >= next_skip_pfn) {
>  			/*
> @@ -807,8 +806,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  		 * It's possible to migrate LRU and non-lru movable pages.
>  		 * Skip any other type of page
>  		 */
> -		is_lru = PageLRU(page);
> -		if (!is_lru) {
> +		if (!PageLRU(page)) {
>  			/*
>  			 * __PageMovable can return false positive so we need
>  			 * to verify it under page_lock.
> --
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
