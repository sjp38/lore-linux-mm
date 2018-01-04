Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0319A6B04FB
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 17:51:44 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id a12so1894041pll.21
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 14:51:43 -0800 (PST)
Received: from out0-231.mail.aliyun.com (out0-231.mail.aliyun.com. [140.205.0.231])
        by mx.google.com with ESMTPS id a15si2644392pgd.183.2018.01.04.14.51.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 14:51:42 -0800 (PST)
Subject: Re: [PATCH 6/8] net: caif: remove unused hardirq.h
From: "Yang Shi" <yang.s@alibaba-inc.com>
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
 <1510959741-31109-6-git-send-email-yang.s@alibaba-inc.com>
 <9ad5b35a-8d4c-448a-912b-2816c4c8c53f@alibaba-inc.com>
Message-ID: <a2f9ddc4-f3e1-4f80-6b05-398d1243e225@alibaba-inc.com>
Date: Fri, 05 Jan 2018 06:51:36 +0800
MIME-Version: 1.0
In-Reply-To: <9ad5b35a-8d4c-448a-912b-2816c4c8c53f@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>, "David S. Miller" <davem@davemloft.net>

Hi David,

I'm not sure if CAIF is still maintained by Dmitry Tarnyagin. Do you 
have any comment on this one?

Thanks,
Yang


On 12/7/17 11:13 AM, Yang Shi wrote:
> Hi folks,
> 
> Any comment on this one?
> 
> Thanks,
> Yang
> 
> 
> On 11/17/17 3:02 PM, Yang Shi wrote:
>> Preempt counter APIs have been split out, currently, hardirq.h just
>> includes irq_enter/exit APIs which are not used by caif at all.
>>
>> So, remove the unused hardirq.h.
>>
>> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
>> Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> ---
>>   net/caif/cfpkt_skbuff.c | 1 -
>>   net/caif/chnl_net.c     | 1 -
>>   2 files changed, 2 deletions(-)
>>
>> diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
>> index 71b6ab2..38c2b7a 100644
>> --- a/net/caif/cfpkt_skbuff.c
>> +++ b/net/caif/cfpkt_skbuff.c
>> @@ -8,7 +8,6 @@
>>   #include <linux/string.h>
>>   #include <linux/skbuff.h>
>> -#include <linux/hardirq.h>
>>   #include <linux/export.h>
>>   #include <net/caif/cfpkt.h>
>> diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
>> index 922ac1d..53ecda1 100644
>> --- a/net/caif/chnl_net.c
>> +++ b/net/caif/chnl_net.c
>> @@ -8,7 +8,6 @@
>>   #define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
>>   #include <linux/fs.h>
>> -#include <linux/hardirq.h>
>>   #include <linux/init.h>
>>   #include <linux/module.h>
>>   #include <linux/netdevice.h>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
