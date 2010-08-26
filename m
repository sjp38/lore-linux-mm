Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1D4926B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 05:39:51 -0400 (EDT)
Received: by iwn33 with SMTP id 33so1893886iwn.14
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 02:39:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100826090305.GC20944@csn.ul.ie>
References: <1282663879-4130-1-git-send-email-minchan.kim@gmail.com>
	<20100826090305.GC20944@csn.ul.ie>
Date: Thu, 26 Aug 2010 18:39:49 +0900
Message-ID: <AANLkTikE-_=8GCu=LjLiyyO9W+soSKAC0bkXfYAnwMux@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] compaction: handle active and inactive fairly in too_many_isolated
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Iram Shahzad <iram.shahzad@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 6:03 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Wed, Aug 25, 2010 at 12:31:18AM +0900, Minchan Kim wrote:
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
>> This patch handles active and inactive with fair.
>> That's because we can't expect where from and how many compaction would
>> isolated pages.
>>
>> This patch changes (nr_isolated > nr_inactive) with
>> nr_isolated > (nr_active + nr_inactive) / 2.
>>
>> Cc: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
>> Acked-by: Mel Gorman <mel@csn.ul.ie>
>> Acked-by: Wu Fengguang <fengguang.wu@intel.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
> Please send this patch on its own as it looks like it should be merged and
> arguably is a stable candidate for 2.6.35. Alternatively, Andrew, can you pick
> up just this patch? It seems unrelated to the second patch on COMPACTPAGEFAILED.

I thought it's not urgent and next patch would apply based on this
patch without HUNK.
If Andrew doesn't have a response, I will resend as a standalone.
Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
