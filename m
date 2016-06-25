Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A81B56B0005
	for <linux-mm@kvack.org>; Sat, 25 Jun 2016 04:21:37 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so35973591wmr.0
        for <linux-mm@kvack.org>; Sat, 25 Jun 2016 01:21:37 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id u184si6873053lja.22.2016.06.25.01.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Jun 2016 01:21:36 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id l184so23935429lfl.1
        for <linux-mm@kvack.org>; Sat, 25 Jun 2016 01:21:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160620143539.GG9892@dhcp22.suse.cz>
References: <1465754611-21398-1-git-send-email-masanori.yoshida.lkml@gmail.com>
 <20160620143539.GG9892@dhcp22.suse.cz>
From: Masanori YOSHIDA <masanori.yoshida.lkml@gmail.com>
Date: Sat, 25 Jun 2016 17:21:35 +0900
Message-ID: <CAM-Ae1O5m-qUqyX=2UBbucb3fTo6WW15DKyfVEJLRTGyDnJYPA@mail.gmail.com>
Subject: Re: [PATCH] Delete meaningless check of current_order in __rmqueue_fallback
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, rientjes@google.com, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, YOSHIDA Masanori <masanori.yoshida@gmail.com>

On Mon, Jun 20, 2016 at 11:35 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 13-06-16 03:03:31, YOSHIDA Masanori wrote:
>> From: YOSHIDA Masanori <masanori.yoshida@gmail.com>
>>
>> Signed-off-by: YOSHIDA Masanori <masanori.yoshida@gmail.com>
>> ---
>>  mm/page_alloc.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 6903b69..db02967 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2105,7 +2105,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>>
>>       /* Find the largest possible block of pages in the other list */
>>       for (current_order = MAX_ORDER-1;
>> -                             current_order >= order && current_order <= MAX_ORDER-1;
>> +                             current_order >= order;
>>                               --current_order) {
>>               area = &(zone->free_area[current_order]);
>>               fallback_mt = find_suitable_fallback(area, current_order,
>
> This is incorrect. Guess what happens if the given order is 0. Hint,
> current_order is unsigned int.

I see. Thank you for replying.
And I should have noticed this before submission by using git-blame. Excuse me.

> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
