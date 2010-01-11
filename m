Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 470176B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 00:13:34 -0500 (EST)
Received: by qyk14 with SMTP id 14so9454246qyk.11
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 21:13:32 -0800 (PST)
Message-ID: <4B4AB375.1060009@gmail.com>
Date: Mon, 11 Jan 2010 13:13:25 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm/page_alloc : relieve the zone->lock's pressure
 for allocation
References: <1263184634-15447-1-git-send-email-shijie8@gmail.com>	<1263184634-15447-2-git-send-email-shijie8@gmail.com> <20100111140215.e5f7049a.minchan.kim@barrios-desktop>
In-Reply-To: <20100111140215.e5f7049a.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


>>    The __mod_zone_page_state() only require irq disabling,
>> it does not require the zone's spinlock. So move it out of
>> the guard region of the spinlock to relieve the pressure for
>> allocation.
>>
>> Signed-off-by: Huang Shijie<shijie8@gmail.com>
>> ---
>>   mm/page_alloc.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 23df1ed..00aa83a 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -961,8 +961,8 @@ static int rmqueue_single(struct zone *zone, unsigned long count,
>>   		set_page_private(page, migratetype);
>>   		list =&page->lru;
>>   	}
>> -	__mod_zone_page_state(zone, NR_FREE_PAGES, -i);
>>   	spin_unlock(&zone->lock);
>> +	__mod_zone_page_state(zone, NR_FREE_PAGES, -i);
>>   	return i;
>>   }
>>
>> -- 
>> 1.6.5.2
>>
>>      
> How about moving this patch into [4/4]?
> Otherwise, Looks good to me.
>
>    
I just  want to make the patches  more clear : two for memory 
allocation, two for memory free.

> Reviewed-by: Minchan Kim<minchan.kim@gmail.com>
>
>    
thanks a lot.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
