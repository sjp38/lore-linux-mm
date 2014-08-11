Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id C8B6C6B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 05:23:53 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so10443378pdb.19
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 02:23:53 -0700 (PDT)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id pf8si9391958pdb.149.2014.08.11.02.23.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 02:23:52 -0700 (PDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 Aug 2014 14:53:48 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 9D818E0019
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 14:55:44 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s7B9O9Gi1376750
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 14:54:10 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s7B9NgqY004774
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 14:53:44 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/8] mm/isolation: remove unstable check for isolated page
In-Reply-To: <1407309517-3270-4-git-send-email-iamjoonsoo.kim@lge.com>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com> <1407309517-3270-4-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 11 Aug 2014 14:53:35 +0530
Message-ID: <87a97b5qi0.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> The check '!PageBuddy(page) && page_count(page) == 0 &&
> migratetype == MIGRATE_ISOLATE' would mean the page on free processing.
> Although it could go into buddy allocator within a short time,
> futher operation such as isolate_freepages_range() in CMA, called after
> test_page_isolated_in_pageblock(), could be failed due to this unstability
> since it requires that the page is on buddy. I think that removing
> this unstability is good thing.

Is that true in case of check_pages_isolated_cb ? Does that require
PageBuddy to be true ?

>
> And, following patch makes isolated freepage has new status matched with
> this condition and this check is the obstacle to that change. So remove
> it.

Can you quote the patch summary in the above case ? ie, something like

And the followiing patch "mm/....." makes isolate freepage.


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
