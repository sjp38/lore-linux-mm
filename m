Message-ID: <400F7965.5050605@cyberone.com.au>
Date: Thu, 22 Jan 2004 18:19:01 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
References: <400F630F.80205@cyberone.com.au>	<20040121223608.1ea30097.akpm@osdl.org>	<400F738A.40505@cyberone.com.au> <20040121230408.7b8b9a92.akpm@osdl.org>
In-Reply-To: <20040121230408.7b8b9a92.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Nikita@Namesys.COM
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Nick Piggin <piggin@cyberone.com.au> wrote:
>
>> By the way, what
>> do you think of this? Did I miss something non obvious?
>>
>> Seems to make little difference on the benchmarks. Without the patch,
>> the active list would generally be attacked more aggressively.
>>
>>
>>
>>[vm-fix-shrink-zone.patch  text/plain (2741 bytes)]
>>
>> Use the actual number of pages difference when trying to keep the inactive
>> list 1/2 the size of the active list (1/3 the size of all pages) instead of
>> a meaningless ratio.
>>
>
>Frankly, that `ratio' thing has always hurt my brain, so I left it as-is
>from 2.4 because it never caused any obvious problems.
>
>If we can put some clearer rationale behind what we're doing in there then
>great.
>

Hmm, I actually did misread it a bit. The ratio is:
nr_pages * zone->nr_active / (zone->nr_inactive * 2)
Which is nr_pages if the active list is size we want.

So its not so bad as I thought. Scaling by nr_pages would
seem to couple it strongly with free pages though. My
patch makes it more independent. No I don't know if thats
good or not, it would obviously need a lot of testing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
