Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 508776B00B8
	for <linux-mm@kvack.org>; Fri,  2 Jan 2009 06:18:59 -0500 (EST)
Received: by yx-out-1718.google.com with SMTP id 36so1817000yxh.26
        for <linux-mm@kvack.org>; Fri, 02 Jan 2009 03:18:57 -0800 (PST)
Message-ID: <28c262360901020318n189cf48bl4081d15adc99e3d9@mail.gmail.com>
Date: Fri, 2 Jan 2009 20:18:57 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: stop kswapd's infinite loop at high order allocation take2
In-Reply-To: <2f11576a0901020254h13d43d2difa340aa1c40a0dbf@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081231115332.GB20534@csn.ul.ie>
	 <20081231215934.1296.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090101021240.A057.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <28c262360901020155l3a9260b5h3c79d4b23a213825@mail.gmail.com>
	 <2f11576a0901020200t3a6dadf5qa944432cd9fd8873@mail.gmail.com>
	 <28c262360901020229k55d47445yc9a6c9c7aa3e9c66@mail.gmail.com>
	 <2f11576a0901020254h13d43d2difa340aa1c40a0dbf@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, wassim dagash <wassim.dagash@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 2, 2009 at 7:54 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>>>> So I want to balance zone's proportional free page.
>>>> How about following ?
>>>>
>>>> if (nr_reclaimed < SWAP_CLUSTER_MAX) {
>>>>   if (order != 0) {
>>>>     order -=1;
>>>>     sc.order -=1;
>>>>   }
>>>> }
>>>>
>>>> It prevents infinite loop and do best effort to make zone's
>>>> proportional free page per order size good.
>>>>
>>>> It's just my opinion within my knowledge.
>>>> If it have a problem, pz, explain me :)
>>>
>>> Please read Nick's expalin. it explain very kindly :)
>>
>> Hm. I read Nick's explain.
>> I understand his point.
>>
>> Nick said,
>> "A higher kswapd reclaim order shouldn't weaken kswapd
>> postcondition for order-0 memory."
>>
>> My patch don't prevent order-0 memory reclaim. After all, it will do it.
>> It also can do best effort to reclaim other order size.
>>
>> In this case, others order size reclaim is needless  ?
>
> Yes, needless.
>
> wakeup_kswapd() function mean
>  - please make free memory until pages_high
>  - and, I want to "order argument" conteniously pages.
>
> then, shorter conteniously pages than "order argumet" pages aren't needed
> by caller.
>
> Unfortunately, your patch has more bad side effect.
> high order shrink_zone() cause lumpy reclaim.
> lumpy reclaim cause reclaim neighbor pages although it is active page.
>
> needlessly active page reclaiming decrease system performance.
>

I agree. It can reclaim active pages.
Thanks for kind explain. :)


-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
