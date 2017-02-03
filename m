Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C82756B0038
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 02:43:14 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f5so14276569pgi.1
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 23:43:14 -0800 (PST)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id j21si19994635pgg.373.2017.02.02.23.43.12
        for <linux-mm@kvack.org>;
        Thu, 02 Feb 2017 23:43:13 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170202191957.22872-1-hannes@cmpxchg.org> <20170202191957.22872-7-hannes@cmpxchg.org>
In-Reply-To: <20170202191957.22872-7-hannes@cmpxchg.org>
Subject: Re: [PATCH 6/7] mm: vmscan: move dirty pages out of the way until they're flushed
Date: Fri, 03 Feb 2017 15:42:55 +0800
Message-ID: <006601d27df1$228a3940$679eabc0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Mel Gorman' <mgorman@suse.de>, 'Michal Hocko' <mhocko@suse.com>, 'Minchan Kim' <minchan.kim@gmail.com>, 'Rik van Riel' <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On February 03, 2017 3:20 AM Johannes Weiner wrote: 
> @@ -1063,7 +1063,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			    PageReclaim(page) &&
>  			    test_bit(PGDAT_WRITEBACK, &pgdat->flags)) {
>  				nr_immediate++;
> -				goto keep_locked;
> +				goto activate_locked;

Out of topic but relevant IMHO, I can't find where it is cleared by grepping:

$ grep -nr PGDAT_WRITEBACK  linux-4.9/mm
linux-4.9/mm/vmscan.c:1019:	test_bit(PGDAT_WRITEBACK, &pgdat->flags)) {
linux-4.9/mm/vmscan.c:1777:	set_bit(PGDAT_WRITEBACK, &pgdat->flags);

It was removed in commit 1d82de618dd 
("mm, vmscan: make kswapd reclaim in terms of nodes")

Is it currently maintained somewhere else, Mel and John?

thanks
Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
