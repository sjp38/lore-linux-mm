Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 27D6D6B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 03:27:28 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id y10so2299226wgg.3
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 00:27:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gt1si19720707wjc.54.2014.09.30.00.27.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Sep 2014 00:27:26 -0700 (PDT)
Message-ID: <542A5B5B.7060207@suse.cz>
Date: Tue, 30 Sep 2014 09:27:23 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, compaction: using uninitialized_var insteads setting
 'flags' to 0 directly.
References: <1411961425-8045-1-git-send-email-Li.Xiubo@freescale.com>
In-Reply-To: <1411961425-8045-1-git-send-email-Li.Xiubo@freescale.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiubo Li <Li.Xiubo@freescale.com>, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, minchan@kernel.org

On 09/29/2014 05:30 AM, Xiubo Li wrote:
> Setting 'flags' to zero will be certainly a misleading way to avoid
> warning of 'flags' may be used uninitialized. uninitialized_var is
> a correct way because the warning is a false possitive.

Agree.

> Signed-off-by: Xiubo Li <Li.Xiubo@freescale.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/compaction.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 92075d5..59a116d 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -344,7 +344,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  {
>  	int nr_scanned = 0, total_isolated = 0;
>  	struct page *cursor, *valid_page = NULL;
> -	unsigned long flags = 0;
> +	unsigned long uninitialized_var(flags);
>  	bool locked = false;
>  	unsigned long blockpfn = *start_pfn;
>  
> @@ -573,7 +573,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  	unsigned long nr_scanned = 0, nr_isolated = 0;
>  	struct list_head *migratelist = &cc->migratepages;
>  	struct lruvec *lruvec;
> -	unsigned long flags = 0;
> +	unsigned long uninitialized_var(flags);
>  	bool locked = false;
>  	struct page *page = NULL, *valid_page = NULL;
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
