Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D37556B007B
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 22:03:02 -0500 (EST)
Received: by yxe10 with SMTP id 10so17257249yxe.12
        for <linux-mm@kvack.org>; Mon, 11 Jan 2010 19:03:01 -0800 (PST)
Message-ID: <4B4BE65F.8090204@gmail.com>
Date: Tue, 12 Jan 2010 11:02:55 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
 memory free
References: <20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com> <20100112022708.GA21621@localhost> <20100112115550.B398.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100112115550.B398.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


>>> I don't want to see additional spin_lock, here.
>>>
>>> About ZONE_ALL_UNRECLAIMABLE, it's not necessary to be handled in atomic way.
>>> If you have concerns with other flags, please modify this with single word,
>>> instead of a bit field.
>>>        
>> I'd second it. It's not a big problem to reset ZONE_ALL_UNRECLAIMABLE
>> and pages_scanned outside of zone->lru_lock.
>>
>> Clear of ZONE_ALL_UNRECLAIMABLE is already atomic; if we lose one
>> pages_scanned=0 due to races, there are plenty of page free events
>> ahead to reset it, before pages_scanned hit the huge
>> zone_reclaimable_pages() * 6.
>>      
> Yes, this patch should be rejected.
>
>
>
>    
What about the new version?
http://marc.info/?l=linux-mm&m=126326472530210&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
