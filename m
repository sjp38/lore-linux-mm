Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BEBD26B009B
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 01:59:23 -0500 (EST)
Received: by rn-out-0910.google.com with SMTP id j71so3060958rne.4
        for <linux-mm@kvack.org>; Tue, 16 Dec 2008 23:01:06 -0800 (PST)
Message-ID: <28c262360812162301i58c9fe9l4a1ee89ca0a6a56@mail.gmail.com>
Date: Wed, 17 Dec 2008 16:01:06 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [rfc][patch] SLQB slab allocator
In-Reply-To: <20081217064238.GA26179@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081212002518.GH8294@wotan.suse.de>
	 <28c262360812151542g2ac032fay6c5b03d846d05a77@mail.gmail.com>
	 <20081217064238.GA26179@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 17, 2008 at 3:42 PM, Nick Piggin <npiggin@suse.de> wrote:
> On Tue, Dec 16, 2008 at 08:42:12AM +0900, MinChan Kim wrote:
>> Hi, Nick.
>> I am interested in SLQB.
>> So I tested slqb, slub, slab by kernel compile time.
>>
>> make all -j 8
>>
>> slqb and slub not DEBUG.
>> my test environment is as follows.
>>
>> cpu family    : 6
>> model         : 15
>> model name    : Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz
>> stepping      : 11
>> cpu MHz               : 1600.000
>> cache size    : 4096 KB
>>
>> Below is average for ten time test.
>>
>> slab :
>> user : 2376.484, system : 192.616 elapsed : 12:22.0
>> slub :
>> user : 2378.439, system : 194.989 elapsed : 12:22.4
>> slqb :
>> user : 2380.556, system : 194.801 elapsed : 12:23.0
>>
>> so, slqb is rather slow although it is a big difference.
>> Interestingly, slqb consumes less time than slub in system.
>
> Thanks, interesting test. kbuild is not very slab allocator intensive,

Let me know what is popular benchmark program in slab allocator.
I will try with it. :)

> so I hadn't thought of trying it. Possibly the object cacheline layout
> of longer lived allocations changes the behaviour (increased user time
> could indicate that).

What mean "object cacheline layout of loger lived allocations" ?

> I've been making a few changes to that, and hopefully slqb is slightly
> improved now (the margin is much closer, seems within the noise with
> SLUB on my NUMA opteron now, although that's a very different system).
>
> The biggest bug I fixed was that the NUMA path wasn't being taken in
> kmem_cache_free on NUMA systems (oops), but that wouldn't change your
> result. But I did make some other changes too, eg in prefetching.

OK. I will review and test your new patch in my machine.

-- 
Kinds regards,
MinChan Kim
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
