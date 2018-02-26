Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC886B000C
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:01:02 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p4so6461726wmc.8
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 10:01:02 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id k129si5758682wme.177.2018.02.26.10.00.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 10:00:59 -0800 (PST)
Subject: Re: [PATCH 2/7] genalloc: selftest
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-3-igor.stoppa@huawei.com>
 <76b3d858-b14e-b66d-d8ae-dbd0b307308a@gmail.com>
 <a7b47f45-5929-ae07-1a10-46a02f6db078@huawei.com>
 <45087800-218a-7ff5-22c0-d0a5bfea5001@gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <20249e10-4a13-8084-bcf2-0f98497a755f@huawei.com>
Date: Mon, 26 Feb 2018 20:00:26 +0200
MIME-Version: 1.0
In-Reply-To: <45087800-218a-7ff5-22c0-d0a5bfea5001@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J Freyensee <why2jjj.linux@gmail.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 26/02/18 19:46, J Freyensee wrote:
> 
> 
> On 2/26/18 4:11 AM, Igor Stoppa wrote:
>>
>> On 24/02/18 00:42, J Freyensee wrote:
>>>> +	locations[action->location] = gen_pool_alloc(pool, action->size);
>>>> +	BUG_ON(!locations[action->location]);
>>> Again, I'd think it through if you really want to use BUG_ON() or not:
>>>
>>> https://lwn.net/Articles/13183/
>>> https://lkml.org/lkml/2016/10/4/1
>> Is it acceptable to display only a WARNing, in case of risking damaging
>> a mounted filesystem?
> 
> That's a good question.A  Based upon those articles, 'yes'.A  But it seems 
> like a 'darned-if-you-do, darned-if-you-don't' question as couldn't you 
> also corrupt a mounted filesystem by crashing the kernel, yes/no?

The idea is to do it very early in the boot phase, before early init,
when the kernel has not gotten even close to any storage device.

> If you really want a system crash, maybe just do a panic() like 
> filesystems also use?

ok, if that's a more acceptable way to halt the kernel, I do not mind.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
