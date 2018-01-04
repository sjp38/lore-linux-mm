Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 856506B04F7
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 17:47:12 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id i12so1899902plk.5
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 14:47:12 -0800 (PST)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTPS id d1si2633705pgo.568.2018.01.04.14.47.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 14:47:11 -0800 (PST)
Subject: Re: [PATCH 8/8] net: tipc: remove unused hardirq.h
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
 <1510959741-31109-8-git-send-email-yang.s@alibaba-inc.com>
 <4ed1efbc-5fb8-7412-4f46-1e3a91a98373@windriver.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <b48afbb6-771f-84b1-8329-d5941eff086b@alibaba-inc.com>
Date: Fri, 05 Jan 2018 06:46:48 +0800
MIME-Version: 1.0
In-Reply-To: <4ed1efbc-5fb8-7412-4f46-1e3a91a98373@windriver.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Cc: Ying Xue <ying.xue@windriver.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>

Hi David,

Any more comment on this change?

Thanks,
Yang


On 12/7/17 5:40 PM, Ying Xue wrote:
> On 11/18/2017 07:02 AM, Yang Shi wrote:
>> Preempt counter APIs have been split out, currently, hardirq.h just
>> includes irq_enter/exit APIs which are not used by TIPC at all.
>>
>> So, remove the unused hardirq.h.
>>
>> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
>> Cc: Jon Maloy <jon.maloy@ericsson.com>
>> Cc: Ying Xue <ying.xue@windriver.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
> 
> Tested-by: Ying Xue <ying.xue@windriver.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>
> 
>> ---
>>   net/tipc/core.h | 1 -
>>   1 file changed, 1 deletion(-)
>>
>> diff --git a/net/tipc/core.h b/net/tipc/core.h
>> index 5cc5398..099e072 100644
>> --- a/net/tipc/core.h
>> +++ b/net/tipc/core.h
>> @@ -49,7 +49,6 @@
>>   #include <linux/uaccess.h>
>>   #include <linux/interrupt.h>
>>   #include <linux/atomic.h>
>> -#include <asm/hardirq.h>
>>   #include <linux/netdevice.h>
>>   #include <linux/in.h>
>>   #include <linux/list.h>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
