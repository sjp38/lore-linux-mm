Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CDB5E6B02FD
	for <linux-mm@kvack.org>; Sun,  3 Sep 2017 21:35:07 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t193so15681022pgc.4
        for <linux-mm@kvack.org>; Sun, 03 Sep 2017 18:35:07 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id g68si4069663pgc.807.2017.09.03.18.35.05
        for <linux-mm@kvack.org>;
        Sun, 03 Sep 2017 18:35:06 -0700 (PDT)
Subject: Re: Re: [PATCH] mm/vmstats: add counters for the page frag cache
References: <1504222631-2635-1-git-send-email-kyeongdon.kim@lge.com>
 <50592560-af4d-302c-c0bc-1e854e35139d@yandex-team.ru>
From: Kyeongdon Kim <kyeongdon.kim@lge.com>
Message-ID: <19156a13-6153-f570-317b-7b80505347e7@lge.com>
Date: Mon, 4 Sep 2017 10:35:00 +0900
MIME-Version: 1.0
In-Reply-To: <50592560-af4d-302c-c0bc-1e854e35139d@yandex-team.ru>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, akpm@linux-foundation.org, sfr@canb.auug.org.au
Cc: ying.huang@intel.com, vbabka@suse.cz, hannes@cmpxchg.org, xieyisheng1@huawei.com, luto@kernel.org, shli@fb.com, mhocko@suse.com, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com, kemi.wang@intel.com, rientjes@google.com, bigeasy@linutronix.de, iamjoonsoo.kim@lge.com, bongkyu.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Thanks for your reply,
But I couldn't find "NR_FRAGMENT_PAGES" in linux-next.git .. is that 
vmstat counter? or others?

As you know, page_frag_alloc() directly calls __alloc_pages_nodemask() 
function,
so that makes too difficult to see memory usage in real time even though 
we have "/meminfo or /slabinfo.." information.
If there was a way already to figure out the memory leakage from 
page_frag_cache in mainline, I agree your opinion
but I think we don't have it now.

If those counters too much in my patch,
I can say two values (pgfrag_alloc and pgfrag_free) are enough to guess 
what will happen
and would remove pgfrag_alloc_calls and pgfrag_free_calls.

Thanks,
Kyeongdon Kim

On 2017-09-01 i??i?? 6:12, Konstantin Khlebnikov wrote:
> IMHO that's too much counters.
> Per-node NR_FRAGMENT_PAGES should be enough for guessing what's going on.
> Perf probes provides enough features for furhter debugging.
>
> On 01.09.2017 02:37, Kyeongdon Kim wrote:
> > There was a memory leak problem when we did stressful test
> > on Android device.
> > The root cause of this was from page_frag_cache alloc
> > and it was very hard to find out.
> >
> > We add to count the page frag allocation and free with function call.
> > The gap between pgfrag_alloc and pgfrag_free is good to to calculate
> > for the amount of page.
> > The gap between pgfrag_alloc_calls and pgfrag_free_calls is for
> > sub-indicator.
> > They can see trends of memory usage during the test.
> > Without it, it's difficult to check page frag usage so I believe we
> > should add it.
> >
> > Signed-off-by: Kyeongdon Kim <kyeongdon.kim@lge.com>
> > ---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
