Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8A77F6B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 13:54:05 -0500 (EST)
Received: by pdjz10 with SMTP id z10so38154790pdj.12
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 10:54:05 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id hb7si11363362pbc.193.2015.02.16.10.54.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 16 Feb 2015 10:54:04 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJV00MQLOOMW2A0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 16 Feb 2015 18:57:58 +0000 (GMT)
Message-id: <54E23CC5.3050706@partner.samsung.com>
Date: Mon, 16 Feb 2015 21:53:57 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 0/4] mm: cma: add some debug information for CMA
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
 <20150213030308.GG6592@js1304-P5Q-DELUXE>
In-reply-to: <20150213030308.GG6592@js1304-P5Q-DELUXE>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Hello Joonsoo,

Thank you for your answer.

On 13/02/15 06:03, Joonsoo Kim wrote:
> On Fri, Feb 13, 2015 at 01:15:40AM +0300, Stefan Strogin wrote:
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

I think, yes, we could solve the problem using only trace events. We
could get all CMA allocations and releases. But if we want to get
the current state of CMA region, for example to know actual
fragmentation, should we parse the tracer's output or what else? IMHO it
would be easier for testers if they have the list of currently allocated
buffers right away.

>>
>> These patches add some files to debugfs when CONFIG_CMA_DEBUGFS is enabled.
> 
> If this tracer is justifiable, I think that making it conditional is
> better than just enabling always on CONFIG_CMA_DEBUGFS. Some users
> don't want to this feature although they enable CONFIG_CMA_DEBUGFS.
> 
> Thanks.
> 

Thank you. I think, this makes sense because of overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
