Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE2EE6B039F
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 03:54:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z109so1341996wrb.1
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 00:54:59 -0700 (PDT)
Received: from dggrg02-dlp.huawei.com ([45.249.212.188])
        by mx.google.com with ESMTPS id f74si6257827wmi.20.2017.03.29.00.54.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 00:54:58 -0700 (PDT)
Subject: Re: [RFC]mm/zsmalloc,: trigger BUG_ON in function zs_map_object.
References: <e8aa282e-ad53-bfb8-2b01-33d2779f247a@huawei.com>
 <20170329002029.GA18979@bbox> <20170329064206.GA512@tigerII.localdomain>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <cb7a4f4f-f6cc-0856-80f7-d42a0ce4e8c8@huawei.com>
Date: Wed, 29 Mar 2017 15:53:21 +0800
MIME-Version: 1.0
In-Reply-To: <20170329064206.GA512@tigerII.localdomain>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

Hi Sergey,

Thanks for your comment!
On 2017/3/29 14:42, Sergey Senozhatsky wrote:
> On (03/29/17 09:20), Minchan Kim wrote:
>> Hello,
>>
>> On Tue, Mar 28, 2017 at 03:20:22PM +0800, Yisheng Xie wrote:
>>> Hi, all,
>>>
>>> We had backport the no-lru migration to linux-4.1, meanwhile change the
>>> ZS_MAX_ZSPAGE_ORDER to 3. Then we met a BUG_ON(!page[1]).
>>
>> Hmm, I don't know how you backported.
>>
>> There isn't any problem with default ZS_MAX_ZSPAGE_ORDER. Right?
>> So, it happens only if you changed it to 3?
> 
> I agree with Minchan. too much things could have gone wrong during the backport.
> 
>> Could you tell me what is your base kernel? and what zram/zsmalloc
>> version(ie, from what kernel version) you backported to your
>> base kernel?
> 
> agree again.
> 
> 
> 
> Yisheng, do you have this commit applied?
No, we missed this patch, I will try it. Really thanks for that.

Thanks
Yisheng Xie

> 
> commit c102f07ca0b04f2cb49cfc161c83f6239d17f491
> Author: Junil Lee <junil0814.lee@lge.com>
> Date:   Wed Jan 20 14:58:18 2016 -0800
> 
>     zsmalloc: fix migrate_zspage-zs_free race condition
> 
> 
> 	-ss
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
