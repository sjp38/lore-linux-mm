Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 73B3C6B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 04:51:31 -0400 (EDT)
Received: by yenm8 with SMTP id m8so1553102yen.14
        for <linux-mm@kvack.org>; Fri, 06 Apr 2012 01:51:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201204061021.39656.b.zolnierkie@samsung.com>
References: <1333643534-1591-1-git-send-email-b.zolnierkie@samsung.com>
	<1333643534-1591-2-git-send-email-b.zolnierkie@samsung.com>
	<CAEwNFnAtzd5GHKanNOafZhnc5xQJHgVZn6y93_+q4BJwRGqwsg@mail.gmail.com>
	<201204061021.39656.b.zolnierkie@samsung.com>
Date: Fri, 6 Apr 2012 17:51:30 +0900
Message-ID: <CAEwNFnDuPX5a59YrFO1FGHoQSj4j=hNRd45vgjDTzCKTh9wugg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: compaction: try harder to isolate free pages
From: Minchan Kim <minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, Kyungmin Park <kyungmin.park@samsung.com>

On Fri, Apr 6, 2012 at 5:21 PM, Bartlomiej Zolnierkiewicz
<b.zolnierkie@samsung.com> wrote:
> On Friday 06 April 2012 08:40:56 Minchan Kim wrote:
>> On Fri, Apr 6, 2012 at 1:32 AM, Bartlomiej Zolnierkiewicz <
>> b.zolnierkie@samsung.com> wrote:
>>
>> > In isolate_freepages() check each page in a pageblock
>> > instead of checking only first pages of pageblock_nr_pages
>> > intervals (suitable_migration_target(page) is called before
>> > isolate_freepages_block() so if page is "unsuitable" whole
>> > pageblock_nr_pages pages will be ommited from the check).
>> > It greatly improves possibility of finding free pages to
>> > isolate during compaction_alloc() phase.
>> >
>>
>> I doubt how this can help keeping free pages.
>> Now, compaction works by pageblock_nr_pages unit so although you work by
>> per page, all pages in a block would have same block type.
>> It means we can't pass suitable_migration_target. No?
>
> suitable_migration_target() only checks first page of pageblock_nr_pages
> block (1024 normal 4KiB pages in my test case cause there is no hugepage
> support on ARM) and pages in pageblock_nr_pages block can have different
> types otherwise I would not see improvement from this patch.

How?
pages in a block should be same type.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
