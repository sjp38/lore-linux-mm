Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC696B039F
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 03:53:05 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r20so2843781wmd.20
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 00:53:04 -0700 (PDT)
Received: from dggrg02-dlp.huawei.com ([45.249.212.188])
        by mx.google.com with ESMTPS id i186si6214680wmg.124.2017.03.29.00.53.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 00:53:03 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: Re: [RFC]mm/zsmalloc,: trigger BUG_ON in function zs_map_object.
References: <e8aa282e-ad53-bfb8-2b01-33d2779f247a@huawei.com>
 <20170329002029.GA18979@bbox>
Message-ID: <4026833d-d639-eb62-c3a8-5c3403ab105f@huawei.com>
Date: Wed, 29 Mar 2017 15:51:23 +0800
MIME-Version: 1.0
In-Reply-To: <20170329002029.GA18979@bbox>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

Hi Minchan,

Thanks for your comment!
On 2017/3/29 8:20, Minchan Kim wrote:
> Hello,
> 
> On Tue, Mar 28, 2017 at 03:20:22PM +0800, Yisheng Xie wrote:
>> Hi, all,
>>
>> We had backport the no-lru migration to linux-4.1, meanwhile change the
>> ZS_MAX_ZSPAGE_ORDER to 3. Then we met a BUG_ON(!page[1]).
> 
> Hmm, I don't know how you backported.
Yes, maybe caused by our unsuitable backport.

> 
> There isn't any problem with default ZS_MAX_ZSPAGE_ORDER. Right?
> So, it happens only if you changed it to 3?
I will check whether it will default ZS_MAX_ZSPAGE_ORDER.

> 
> Could you tell me what is your base kernel? and what zram/zsmalloc
> version(ie, from what kernel version) you backported to your
> base kernel?
> 
We backport from kernel v4.8-rc8 to kernel v4.1.

>>
>> It rarely happen, and presently, what I get is:
>> [6823.316528s]obj=a160701f, obj_idx=15, class{size:2176,objs_per_zspage:15,pages_per_zspage:8}
>> [...]
>> [6823.316619s]BUG: failure at /home/ethan/kernel/linux-4.1/mm/zsmalloc.c:1458/zs_map_object()! ----> BUG_ON(!page[1])
>>
>> It seems that we have allocated an object from a ZS_FULL group?
>> (Actuallyi 1/4 ? I do not get the inuse number of this zspage, which I am trying to.)
>> And presently, I can not find why it happened. Any idea about it?
> 
> Although it happens rarely, always above same symptom once it happens?
Yes , though the class size is not the same, which means not from the same class.
however, the (obj_idx == objs_per_zspage) is always true.

Thanks
Yisheng Xie.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
