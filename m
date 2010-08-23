Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A2D0D6B03A6
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 05:07:43 -0400 (EDT)
Received: by iwn33 with SMTP id 33so4195119iwn.14
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 02:07:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100823071610.GL19797@csn.ul.ie>
References: <20100817111018.GQ19797@csn.ul.ie>
	<4385155269B445AEAF27DC8639A953D7@rainbow>
	<20100818154130.GC9431@localhost>
	<565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
	<20100819160006.GG6805@barrios-desktop>
	<AA3F2D89535A431DB91FE3032EDCB9EA@rainbow>
	<20100820053447.GA13406@localhost>
	<20100820093558.GG19797@csn.ul.ie>
	<AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com>
	<20100822153121.GA29389@barrios-desktop>
	<20100823071610.GL19797@csn.ul.ie>
Date: Mon, 23 Aug 2010 18:07:41 +0900
Message-ID: <AANLkTikOvsH38K0j7ETOfY08AbzvfHd72otw-JTesh-4@mail.gmail.com>
Subject: Re: compaction: trying to understand the code
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Iram Shahzad <iram.shahzad@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 4:16 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Mon, Aug 23, 2010 at 12:31:21AM +0900, Minchan Kim wrote:
>> <SNIP>
>>
>> From 560e8898295c663f02aede07b3d55880eba16c69 Mon Sep 17 00:00:00 2001
>> From: Minchan Kim <minchan.kim@gmail.com>
>> Date: Mon, 23 Aug 2010 00:20:44 +0900
>> Subject: [PATCH] compaction: handle active and inactive fairly in too_many_isolated
>>
>> Iram reported compaction's too_many_isolated loops forever.
>> (http://www.spinics.net/lists/linux-mm/msg08123.html)
>>
>> The meminfo of situation happened was inactive anon is zero.
>> That's because the system has no memory pressure until then.
>> While all anon pages was in active lru, compaction could select
>> active lru as well as inactive lru. That's different things
>> with vmscan's isolated. So we has been two too_many_isolated.
>>
>> While compaction can isolated pages in both active and inactive,
>> current implementation of too_many_isolated only considers inactive.
>> It made Iram's problem.
>>
>> This patch handles active and inactie with fair.
>> That's because we can't expect where from and how many compaction would
>> isolated pages.
>>
>> This patch changes (nr_isolated > nr_inactive) with
>> nr_isolated > (nr_active + nr_inactive) / 2.
>>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
> Seems reasonable to me.
>
> Acked-by: Mel Gorman <mel@csn.ul.ie>

Thanks.

>
> Want to repost this as a standalone patch?

Yes. It is enough to be a standalone.
I will repost the patch as removing part about reporting Iram's problem.

We need to dig in Iram's problem regardless of this patch.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
