Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1E6486B00B3
	for <linux-mm@kvack.org>; Fri,  2 Jan 2009 05:29:18 -0500 (EST)
Received: by gxk12 with SMTP id 12so3703144gxk.14
        for <linux-mm@kvack.org>; Fri, 02 Jan 2009 02:29:17 -0800 (PST)
Message-ID: <28c262360901020229k55d47445yc9a6c9c7aa3e9c66@mail.gmail.com>
Date: Fri, 2 Jan 2009 19:29:16 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: stop kswapd's infinite loop at high order allocation take2
In-Reply-To: <2f11576a0901020200t3a6dadf5qa944432cd9fd8873@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081231115332.GB20534@csn.ul.ie>
	 <20081231215934.1296.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090101021240.A057.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <28c262360901020155l3a9260b5h3c79d4b23a213825@mail.gmail.com>
	 <2f11576a0901020200t3a6dadf5qa944432cd9fd8873@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, wassim dagash <wassim.dagash@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 2, 2009 at 7:00 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> Hi, kosaki-san.
>>
>> I read the previous threads now. It's rather late :(.
>>
>> I think it's rather awkward that sudden big change of order from 10 to 0.
>>
>> This problem causes zone_water_mark's fail.
>> It mean now this zone's proportional free page per order size is not good.
>> Although order-0 page is very important, Shouldn't we consider other
>> order allocations ?
>>
>> So I want to balance zone's proportional free page.
>> How about following ?
>>
>> if (nr_reclaimed < SWAP_CLUSTER_MAX) {
>>   if (order != 0) {
>>     order -=1;
>>     sc.order -=1;
>>   }
>> }
>>
>> It prevents infinite loop and do best effort to make zone's
>> proportional free page per order size good.
>>
>> It's just my opinion within my knowledge.
>> If it have a problem, pz, explain me :)
>
> Please read Nick's expalin. it explain very kindly :)

Hm. I read Nick's explain.
I understand his point.

Nick said,
"A higher kswapd reclaim order shouldn't weaken kswapd
postcondition for order-0 memory."

My patch don't prevent order-0 memory reclaim. After all, it will do it.
It also can do best effort to reclaim other order size.

In this case, others order size reclaim is needless  ?


-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
