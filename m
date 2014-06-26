Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4CAA26B00B4
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 19:23:59 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so3783828pad.21
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 16:23:58 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ra4si11811831pbb.78.2014.06.26.16.23.57
        for <linux-mm@kvack.org>;
        Thu, 26 Jun 2014 16:23:58 -0700 (PDT)
Message-ID: <53ACAB82.6020201@lge.com>
Date: Fri, 27 Jun 2014 08:23:46 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC] CMA page migration failure due to buffers on bh_lru
References: <53A8D092.4040801@lge.com> <xa1td2dvmznq.fsf@mina86.com>
In-Reply-To: <xa1td2dvmznq.fsf@mina86.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>



2014-06-27 i??i ? 12:57, Michal Nazarewicz i?' e,?:
> On Tue, Jun 24 2014, Gioh Kim <gioh.kim@lge.com> wrote:
>> Hello,
>>
>> I am trying to apply CMA feature for my platform.
>> My kernel version, 3.10.x, is not allocating memory from CMA area so that I applied
>> a Joonsoo Kim's patch (https://lkml.org/lkml/2014/5/28/64).
>> Now my platform can use CMA area effectively.
>>
>> But I have many failures to allocate memory from CMA area.
>> I found the same situation to Laura Abbott's patch descrbing,
>> https://lkml.org/lkml/2012/8/31/313,
>> that releases buffer-heads attached at CPU's LRU list.
>>
>> If Joonsoo's patch is applied and/or CMA feature is applied more and more,
>> buffer-heads problem is going to be serious definitely.
>>
>> Please look into the Laura's patch again.
>> I think it must be applied with Joonsoo's patch.
>
> Just to make sure I understood you correctly, you're saying Laura's
> patch at <https://lkml.org/lkml/2012/8/31/313> fixes your issue?
>

Yes, it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
