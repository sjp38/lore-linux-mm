Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 557AE6B0078
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 10:34:22 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f12so27899222qad.10
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 07:34:22 -0800 (PST)
Received: from mail-qa0-x236.google.com (mail-qa0-x236.google.com. [2607:f8b0:400d:c00::236])
        by mx.google.com with ESMTPS id e13si597282qaq.33.2015.01.20.07.34.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 07:34:21 -0800 (PST)
Received: by mail-qa0-f54.google.com with SMTP id w8so27960436qac.13
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 07:34:20 -0800 (PST)
Message-ID: <54BE7547.6010701@gmail.com>
Date: Tue, 20 Jan 2015 23:33:27 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] CMA: treat free cma pages as non-free if not ALLOC_CMA
 on watermark checking
References: <1421569979-2596-1-git-send-email-teawater@gmail.com> <20150119065544.GA18473@blaptop>
In-Reply-To: <20150119065544.GA18473@blaptop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Hui Zhu <teawater@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, isimatu.yasuaki@jp.fujitsu.com, wangnan0@huawei.com, davidlohr@hp.com, cl@linux.com, rientjes@google.com, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hui Zhu <zhuhui@xiaomi.com>, Weixing Liu <liuweixing@xiaomi.com>

Hello Minchan,

How are you?

a?? 2015/1/19 14:55, Minchan Kim a??e??:
> Hello,
> 
> On Sun, Jan 18, 2015 at 04:32:59PM +0800, Hui Zhu wrote:
>> From: Hui Zhu <zhuhui@xiaomi.com>
>>
>> The original of this patch [1] is part of Joonsoo's CMA patch series.
>> I made a patch [2] to fix the issue of this patch.  Joonsoo reminded me
>> that this issue affect current kernel too.  So made a new one for upstream.
> 
> Recently, we found many problems of CMA and Joonsoo tried to add more
> hooks into MM like agressive allocation but I suggested adding new zone

Just out of curiosity, "new zone"? Something like movable zone?

Thanks.

> would be more desirable than more hooks in mm fast path in various aspect.
> (ie, remove lots of hooks in hot path of MM, don't need reclaim hooks
>  for special CMA pages, don't need custom fair allocation for CMA).
> 
> Joonsoo is investigating the direction so please wait.
> If it turns out we have lots of hurdle to go that way,
> this direction(ie, putting more hooks) should be second plan.
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
