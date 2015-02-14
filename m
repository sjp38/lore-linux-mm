Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id A17B16B0074
	for <linux-mm@kvack.org>; Sat, 14 Feb 2015 02:40:40 -0500 (EST)
Received: by pdjp10 with SMTP id p10so24165848pdj.3
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 23:40:40 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id bz4si4115036pdb.113.2015.02.13.23.40.38
        for <linux-mm@kvack.org>;
        Fri, 13 Feb 2015 23:40:39 -0800 (PST)
Message-ID: <54DEFBF4.40206@lge.com>
Date: Sat, 14 Feb 2015 16:40:36 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] mm: cma: add some debug information for CMA
References: <cover.1423777850.git.s.strogin@partner.samsung.com> <20150213030308.GG6592@js1304-P5Q-DELUXE>
In-Reply-To: <20150213030308.GG6592@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Stefan Strogin <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, pavel@ucw.cz, stefan.strogin@gmail.com



2015-02-13 i??i?? 12:03i?? Joonsoo Kim i?'(e??) i?' e,?:
> On Fri, Feb 13, 2015 at 01:15:40AM +0300, Stefan Strogin wrote:
>> Hi all.
>>
>> Sorry for the long delay. Here is the second attempt to add some facility
>> for debugging CMA (the first one was "mm: cma: add /proc/cmainfo" [1]).
>>
>> This patch set is based on v3.19 and Sasha Levin's patch set
>> "mm: cma: debugfs access to CMA" [2].
>> It is also available on git:
>> git://github.com/stefanstrogin/cmainfo -b cmainfo-v2
>>
>> We want an interface to see a list of currently allocated CMA buffers and
>> some useful information about them (like /proc/vmallocinfo but for physically
>> contiguous buffers allocated with CMA).
>>
>> Here is an example use case when we need it. We want a big (megabytes)
>> CMA buffer to be allocated in runtime in default CMA region. If someone
>> already uses CMA then the big allocation can fail. If it happens then with
>> such an interface we could find who used CMA at the moment of failure, who
>> caused fragmentation (possibly ftrace also would be helpful here) and so on.
>
> Hello,
>
> So, I'm not sure that information about allocated CMA buffer is really
> needed to solve your problem. You just want to know who uses default CMA
> region and you can know it by adding tracepoint in your 4/4 patch. We
> really need this custom allocation tracer? What can we do more with
> this custom tracer to solve your problem? Could you more specific
> about your problem and how to solve it by using this custom tracer?
>
>>
>> These patches add some files to debugfs when CONFIG_CMA_DEBUGFS is enabled.
>
> If this tracer is justifiable, I think that making it conditional is
> better than just enabling always on CONFIG_CMA_DEBUGFS. Some users
> don't want to this feature although they enable CONFIG_CMA_DEBUGFS.
>
> Thanks.
>

Hello,

Thanks for your work. It must be helpful to me.

What about add another option to activate stack-trace?
In my platform I know all devices using cma area, so I usually don't need stack-trace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
