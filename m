Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 58E136B007E
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 20:33:22 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 124so4617483pfg.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 17:33:22 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id i76si44703404pfj.182.2016.03.02.17.33.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 17:33:21 -0800 (PST)
Message-ID: <56D792DD.5010202@huawei.com>
Date: Thu, 3 Mar 2016 09:26:53 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: a question about slub in function __slab_free()
References: <56D6DC13.8060008@huawei.com> <CAAmzW4OV4J_zGh2MSCqE0-x6Z_BopB+ucSVLV6kp53Cw4obkfg@mail.gmail.com>
In-Reply-To: <CAAmzW4OV4J_zGh2MSCqE0-x6Z_BopB+ucSVLV6kp53Cw4obkfg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 2016/3/2 22:38, Joonsoo Kim wrote:

> 2016-03-02 21:26 GMT+09:00 Xishi Qiu <qiuxishi@huawei.com>:
>> ___slab_alloc()
>>         deactivate_slab()
>>                 add_full(s, n, page);
>> The page will be added to full list and the frozen is 0, right?
>>
>> __slab_free()
>>         prior = page->freelist;  // prior is NULL
>>         was_frozen = new.frozen;  // was_frozen is 0
>>         ...
>>                 /*
>>                  * Slab was on no list before and will be
>>                  * partially empty
>>                  * We can defer the list move and instead
>>                  * freeze it.
>>                  */
>>                 new.frozen = 1;
>>         ...
>>
>> I don't understand why "Slab was on no list before"?
> 
> add_full() is defined only for CONFIG_SLUB_DEBUG.
> And, actual add happens if slub_debug=u is enabled.
> In other cases, fully used slab isn't attached on any list.
> 
> Thanks.
> 

Hi Joonsoo,

You are right, thank you very much!

> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
