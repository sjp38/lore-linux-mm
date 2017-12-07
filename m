Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 937626B0272
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:15:18 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w1so5842746pgq.21
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:15:18 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTPS id z11si4184194pgc.454.2017.12.07.11.15.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 11:15:17 -0800 (PST)
Subject: Re: [PATCH 7/8] net: ovs: remove unused hardirq.h
From: "Yang Shi" <yang.s@alibaba-inc.com>
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
 <1510959741-31109-7-git-send-email-yang.s@alibaba-inc.com>
 <7877c3bd-74ec-a7d2-61d3-85a4c452e710@alibaba-inc.com>
Message-ID: <a9213170-3cc2-8267-d1f5-53078db7fdb2@alibaba-inc.com>
Date: Fri, 08 Dec 2017 03:14:58 +0800
MIME-Version: 1.0
In-Reply-To: <7877c3bd-74ec-a7d2-61d3-85a4c452e710@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, pshelar@ovn.org, "David S. Miller" <davem@davemloft.net>, dev@openvswitch.org

Hi folks,

Any comment on this one?

Thanks,
Yang


On 11/17/17 5:48 PM, Yang Shi wrote:
> It looks the email address of Pravin in MAINTAINERS file is obsolete, 
> sent to the right address.
> 
> Yang
> 
> 
> On 11/17/17 3:02 PM, Yang Shi wrote:
>> Preempt counter APIs have been split out, currently, hardirq.h just
>> includes irq_enter/exit APIs which are not used by openvswitch at all.
>>
>> So, remove the unused hardirq.h.
>>
>> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
>> Cc: Pravin Shelar <pshelar@nicira.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: dev@openvswitch.org
>> ---
>>   net/openvswitch/vport-internal_dev.c | 1 -
>>   1 file changed, 1 deletion(-)
>>
>> diff --git a/net/openvswitch/vport-internal_dev.c 
>> b/net/openvswitch/vport-internal_dev.c
>> index 04a3128..2f47c65 100644
>> --- a/net/openvswitch/vport-internal_dev.c
>> +++ b/net/openvswitch/vport-internal_dev.c
>> @@ -16,7 +16,6 @@
>>    * 02110-1301, USA
>>    */
>> -#include <linux/hardirq.h>
>>   #include <linux/if_vlan.h>
>>   #include <linux/kernel.h>
>>   #include <linux/netdevice.h>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
