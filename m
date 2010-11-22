Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 425676B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 20:26:50 -0500 (EST)
Message-ID: <4CE9C6CF.20105@redhat.com>
Date: Sun, 21 Nov 2010 20:26:39 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: Make move_active_pages_to_lru more generic
References: <1290349496-13297-1-git-send-email-minchan.kim@gmail.com>	<4CE95FD7.1060805@redhat.com> <AANLkTimSE2j71uFPCZWBFdau4NE_hmTtTMvUOBWOdMhF@mail.gmail.com>
In-Reply-To: <AANLkTimSE2j71uFPCZWBFdau4NE_hmTtTMvUOBWOdMhF@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On 11/21/2010 07:49 PM, Minchan Kim wrote:
> On Mon, Nov 22, 2010 at 3:07 AM, Rik van Riel<riel@redhat.com>  wrote:
>> On 11/21/2010 09:24 AM, Minchan Kim wrote:
>>>
>>> Now move_active_pages_to_lru can move pages into active or inactive.
>>> if it moves the pages into inactive, it itself can clear PG_acive.
>>> It makes the function more generic.
>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index aa4f1cb..bd408b3 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -1457,6 +1457,10 @@ static void move_active_pages_to_lru(struct zone
>>> *zone,
>>>                 VM_BUG_ON(PageLRU(page));
>>>                 SetPageLRU(page);
>>>
>>> +               /* we are de-activating */
>>> +               if (!is_active_lru(lru))
>>> +                       ClearPageActive(page);
>>> +
>>
>> Does that mean we also want code to ensure that pages have
>> the PG_active bit set when we add them to an active list?
>
> Yes. the function name is move_"active"_pages_to_lru.
> So  caller have to make sure pages have PG_active.

Good point.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
