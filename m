Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7F46B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 07:58:49 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id va2so23697313obc.7
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 04:58:49 -0800 (PST)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id wo10si5262914oeb.19.2015.01.30.04.58.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 04:58:49 -0800 (PST)
Received: by mail-ob0-f182.google.com with SMTP id nt9so2468239obb.13
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 04:58:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54CAF9A4.1040606@samsung.com>
References: <CABymUCNMjM2KHXXB-LM=x+FTcJL6S5_jhG3GbP7VRi2vBoW49g@mail.gmail.com>
	<CABymUCO+xaify95bUqfbCLsEjkLzEC0yT_fgkhV+qzC36JNgoA@mail.gmail.com>
	<CABymUCPgEh93QsBtRyg0S+FyE0FHwjAF75qk+NWh5TS8ehWuew@mail.gmail.com>
	<54CAF314.4070301@linaro.org>
	<54CAF9A4.1040606@samsung.com>
Date: Fri, 30 Jan 2015 21:58:48 +0900
Message-ID: <CAAmzW4OfrKt0XK5bDO0TNR5Ofv=rLDkpS7HAOCk0NRV1WdOhNg@mail.gmail.com>
Subject: Re: CMA related memory questions
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: Jun Nie <jun.nie@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Shawn Guo <shawn.guo@linaro.org>, "mark.brown@linaro.org, wan.zhijun" <wan.zhijun@zte.com.cn>, linux-arm-kernel@lists.infradead.org, Linux Memory Management List <linux-mm@kvack.org>, sunae.seo@samsung.com, cmlaika.kim@samsung.com

2015-01-30 12:25 GMT+09:00 Heesub Shin <heesub.shin@samsung.com>:
>
>
> On 01/30/2015 11:57 AM, Jun Nie wrote:
>>
>> On 2015=E5=B9=B401=E6=9C=8830=E6=97=A5 10:36, Jun Nie wrote:
>>>
>>> Hi Marek & Arnd,
>>>
>>> Did you ever know issue that free CMA memory is high, but system is
>>> hungry for memory and page cache is very low? I am enabling CMA in
>>> Android on my board with 512MB memory and see FreeMem in /proc/meminfo
>>> increase a lot with CMA comparing the reservation solution on boot. But
>>> I find system is not borrowing memory from CMA pool when running 3dmark
>>> (high webkit workload at start). Because the FreeMem size is high, but
>>> cache size decreasing significantly to several MB during benchmark run,
>>> I suppose system is trying to reclaim memory from pagecache for new
>>> allocation. My question is that what API that page cache and webkit
>>> related functionality are using to allocate memory. Maybe page cache
>>> require memory that is not movable/reclaimable memory, where we may hav=
e
>>> optimization to go thru dma_alloc_xxx to borrow CMA memory? I suppose
>>> app level memory allocation shall be movable/reclaimable memory and can
>>> borrow from CMA pool, but not sure whether the flag match the
>>> movable/reclaimable memory and go thru the right path.

Hello,

Maybe, you experienced the problem what I tried to solve.
CMA freepage allocation logic in mainline doesn't work well now since
they are only allocated in fallback case. See below link for detailed
explanation.

https://lkml.org/lkml/2014/5/28/64

This problem can be solved by aggressive allocation approach in that link, =
but,
there are too many issues left in CMA. So, I'm trying to implement ZONE_CMA
now. Prototyping is nearly finished so I will send it soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
