Message-ID: <4020C738.4010903@cyberone.com.au>
Date: Wed, 04 Feb 2004 21:19:36 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm improvements
References: <4020BDCB.8030707@cyberone.com.au>	<4020BE77.7040303@cyberone.com.au> <20040204021153.13bb31a1.akpm@osdl.org>
In-Reply-To: <20040204021153.13bb31a1.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Nick Piggin <piggin@cyberone.com.au> wrote:
>
>>+	if (zone->nr_active >= zone->nr_inactive*4)
>> +		/* ratio will be >= 2 */
>> +		imbalance = 8*nr_pages;
>> +	else if (zone->nr_active >= zone->nr_inactive*2)
>> +		/* 1 < ratio < 2 */
>> +		imbalance = 4*nr_pages*zone->nr_active / (zone->nr_inactive*2);
>>
>
>This can cause a divide-by-zero, yes?
>
>

Yes. Sorry. I guess just adding 1 to the divisor should be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
