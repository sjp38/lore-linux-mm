Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id E6A836B002B
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 03:46:06 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AC48D3EE0C0
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 16:46:04 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 916E045DE51
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 16:46:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 78E0445DE50
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 16:46:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B09C1DB8040
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 16:46:04 +0900 (JST)
Received: from G01JPEXCHKW21.g01.fujitsu.local (G01JPEXCHKW21.g01.fujitsu.local [10.0.193.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 200411DB8037
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 16:46:04 +0900 (JST)
Message-ID: <50597829.9010801@jp.fujitsu.com>
Date: Wed, 19 Sep 2012 16:45:45 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 1/4] mm: fix tracing in free_pcppages_bulk()
References: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com> <1347632974-20465-2-git-send-email-b.zolnierkie@samsung.com> <50596F27.4080208@jp.fujitsu.com> <20120919073245.GA13234@bbox>
In-Reply-To: <20120919073245.GA13234@bbox>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com

Hi Minchan,

2012/09/19 16:32, Minchan Kim wrote:
> Hi Yasuaki,
>
> On Wed, Sep 19, 2012 at 04:07:19PM +0900, Yasuaki Ishimatsu wrote:
>> Hi Bartlomiej,
>>
>> 2012/09/14 23:29, Bartlomiej Zolnierkiewicz wrote:
>>> page->private gets re-used in __free_one_page() to store page order
>>> (so trace_mm_page_pcpu_drain() may print order instead of migratetype)
>>> thus migratetype value must be cached locally.
>>>
>>> Fixes regression introduced in a701623 ("mm: fix migratetype bug
>>> which slowed swapping").
>>
>> I think the regression has been alreadly fixed by following Mincahn's patches.
>>
>> https://lkml.org/lkml/2012/9/6/635
>>
>> => Hi Minchan,
>>
>>     Am I wrong?
>
> This patch isn't related to mine.

According to the description, the regression occurs by clearing migratetype
info from page->private at __free_one_page(). If we apply your patches,
migratetype info is stored into page->index. So the migratetype info is not
cleared. Thus we do not need to cache the info locally.

Thanks,
Yasuaki Ishimatsu

> In addition, this patch don't need to be a part of this series.
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
