Message-ID: <403C7181.6050103@cyberone.com.au>
Date: Wed, 25 Feb 2004 20:57:21 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: More vm benchmarking
References: <403C66D2.6010302@cyberone.com.au> <20040225014757.4c79f2af.akpm@osdl.org>
In-Reply-To: <20040225014757.4c79f2af.akpm@osdl.org>
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
>>kernel | run | -j5 | -j10 | -j15 |
>> 2.6.3    1     136   886    2511
>> 2.6.3    2     150   838    2465
>>
>> -mm2     1     136   646    1484
>> -mm2     2     142   676    1265
>>
>> -mm3     1     135   881    1828
>> -mm3     2     146   790    1844
>>
>> This quite clearly shows your patches hurting as I told you.
>>
>
>Probably.  But these differences are small, relative to some differences
>wrt 2.4.x
>
>

2.4 should be pretty close to -mm2 for -j10 and hopefully a
bit worse at -j15. That is what previous benchmarks have been
showing anyway. I better get some 2.4 numbers.

Either way, they're not that small.

>>Why did it get slower?
>>
>
>Dunno.  Maybe the workload prefers imbalanced zone scanning.
>
>

Seriously? I find that a bit hard to swallow. Especially
considering I wouldn't have anything that uses ZONE_DMA
on this system.

>>I assume it is because the batching patch places uneven
>> pressure on normal and DMA zones.
>>
>
>The patch improves highmem-vs-lowmem balancing from 10:1 to 1:1.  What
>makes you think that it worsens ZONE_NORMAL-vs-ZONE_DMA balancing?
>
>It's easy enough to instrument - just split pgsteal_lo into pgsteal_normal
>and pgsteal_dma.
>
>

Sure that can tell you if something is really wrong, but it
is pretty hard to read much from that.

Anyway I don't have code or numbers right now so that means
I have to shut up ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
