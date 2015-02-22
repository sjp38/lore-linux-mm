Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9276B0032
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 18:29:10 -0500 (EST)
Received: by pabkx10 with SMTP id kx10so22822142pab.13
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 15:29:10 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id fk16si2366455pac.105.2015.02.22.15.29.08
        for <linux-mm@kvack.org>;
        Sun, 22 Feb 2015 15:29:09 -0800 (PST)
Message-ID: <54EA6641.3010207@lge.com>
Date: Mon, 23 Feb 2015 08:29:05 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] mm: cma: add some debug information for CMA
References: <cover.1423777850.git.s.strogin@partner.samsung.com> <20150213030308.GG6592@js1304-P5Q-DELUXE> <54DEFBF4.40206@lge.com> <54E24517.6040108@partner.samsung.com>
In-Reply-To: <54E24517.6040108@partner.samsung.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, pavel@ucw.cz, stefan.strogin@gmail.com



2015-02-17 i??i ? 4:29i?? Stefan Strogin i?'(e??) i?' e,?:
> Hello Gioh,
>
> Thank you for your answer.
>
> On 14/02/15 10:40, Gioh Kim wrote:
>>>
>>> If this tracer is justifiable, I think that making it conditional is
>>> better than just enabling always on CONFIG_CMA_DEBUGFS. Some users
>>> don't want to this feature although they enable CONFIG_CMA_DEBUGFS.
>>>
>>> Thanks.
>>>
>>
>> Hello,
>>
>> Thanks for your work. It must be helpful to me.
>>
>> What about add another option to activate stack-trace?
>> In my platform I know all devices using cma area, so I usually don't
>> need stack-trace.
>>
>
> So Joonsoo suggests to add an option for buffer list, and you suggest to
> add another in addition to the first one (and also add CONFIG_STACKTRACE
> to dependences) right?
>

Right. Another option for only stack-trace might be good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
