Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9C1336B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 21:03:01 -0500 (EST)
Received: by gxk8 with SMTP id 8so18295962gxk.11
        for <linux-mm@kvack.org>; Mon, 11 Jan 2010 18:02:58 -0800 (PST)
Message-ID: <4B4BD849.7050007@gmail.com>
Date: Tue, 12 Jan 2010 10:02:49 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
 memory free
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com>	<1263191277-30373-1-git-send-email-shijie8@gmail.com>	<20100111153802.f3150117.minchan.kim@barrios-desktop> <20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>


>> Thanks, Huang.
>>
>> Frankly speaking, I am not sure this ir right way.
>> This patch is adding to fine-grained locking overhead
>>
>> As you know, this functions are one of hot pathes.
>> In addition, we didn't see the any problem, until now.
>> It means out of synchronization in ZONE_ALL_UNRECLAIMABLE
>> and pages_scanned are all right?
>>
>> If it is, we can move them out of zone->lock, too.
>> If it isn't, we need one more lock, then.
>>
>>      
> I don't want to see additional spin_lock, here.
>    
I don't want it either.
> About ZONE_ALL_UNRECLAIMABLE, it's not necessary to be handled in atomic way.
> If you have concerns with other flags, please modify this with single word,
> instead of a bit field.
>
>    
How about the `pages_scanned' ?
It's protected by the zone->lru_lock in shrink_{in}active_list().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
