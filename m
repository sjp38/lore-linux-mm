Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2B586B04FA
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 17:48:05 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id i33so1909792pld.0
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 14:48:05 -0800 (PST)
Received: from out0-235.mail.aliyun.com (out0-235.mail.aliyun.com. [140.205.0.235])
        by mx.google.com with ESMTPS id l1si2958565pld.20.2018.01.04.14.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 14:48:04 -0800 (PST)
Subject: Re: [ovs-dev] [PATCH 7/8] net: ovs: remove unused hardirq.h
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
 <1510959741-31109-7-git-send-email-yang.s@alibaba-inc.com>
 <CAOrHB_CiK-A0nphB2xVTG_5P_xeFOkg0xc6iNNbT=MXq1XgU=A@mail.gmail.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <b3be5368-7c7c-d2dd-907b-3c2deb34a80e@alibaba-inc.com>
Date: Fri, 05 Jan 2018 06:47:57 +0800
MIME-Version: 1.0
In-Reply-To: <CAOrHB_CiK-A0nphB2xVTG_5P_xeFOkg0xc6iNNbT=MXq1XgU=A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Pravin Shelar <pshelar@ovn.org>, linux-kernel@vger.kernel.org, ovs dev <dev@openvswitch.org>, Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm@kvack.org, Pravin Shelar <pshelar@nicira.com>, linux-crypto@vger.kernel.org, linux-fsdevel@vger.kernel.org

Hi David,

Any comment is appreciated.

Thanks,
Yang


On 12/7/17 11:27 AM, Pravin Shelar wrote:
> On Fri, Nov 17, 2017 at 3:02 PM, Yang Shi <yang.s@alibaba-inc.com> wrote:
>> Preempt counter APIs have been split out, currently, hardirq.h just
>> includes irq_enter/exit APIs which are not used by openvswitch at all.
>>
>> So, remove the unused hardirq.h.
>>
>> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
>> Cc: Pravin Shelar <pshelar@nicira.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: dev@openvswitch.org
> 
> Acked-by: Pravin B Shelar <pshelar@ovn.org>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
