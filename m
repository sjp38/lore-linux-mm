Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7337D6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 04:45:16 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id p194so64208226iod.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 01:45:16 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id o198si43184443ioe.212.2016.05.31.01.45.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 01:45:15 -0700 (PDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0O8101S0B9ND8T80@mailout2.samsung.com> for linux-mm@kvack.org;
 Tue, 31 May 2016 17:45:14 +0900 (KST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: Re: Re: [RESEND][PATCH] drivers: of: of_reserved_mem: fixup the CMA
 alignment not to affect dma-coherent
Message-id: <574D4F1B.4000702@samsung.com>
Date: Tue, 31 May 2016 17:45:15 +0900
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robh+dt@kernel.org, m.szyprowski@samsung.com
Cc: r64343@freescale.com, grant.likely@linaro.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaewon31.kim@gmail.com

>Hello,
>
>
>On 2016-05-25 16:38, Rob Herring wrote:
>> On Tue, May 24, 2016 at 11:29 PM, Jaewon Kim <jaewon31.kim@samsung.com> wrote:
>>> From: Jaewon <jaewon31.kim@samsung.com>
>>>
>>> There was an alignment mismatch issue for CMA and it was fixed by
>>> commit 1cc8e3458b51 ("drivers: of: of_reserved_mem: fixup the alignment with CMA setup").
>>> However the way of the commit considers not only dma-contiguous(CMA) but also
>>> dma-coherent which has no that requirement.
>>>
>>> This patch checks more to distinguish dma-contiguous(CMA) from dma-coherent.
>>>
>>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>> I suppose this needs to go to stable? If so, adding the stable tag and
>> kernel version would be nice so I don't have to.

Hello

In my opinion, this patch is not that critical.
Commit 1cc8e3458b51 might move unaligned(pageblock size) dma-coherent region.
And this patch will move the region back to different address which is aligned less than pageblock size.
But if you think it need to stable branch, please let me know how to add the stable tag.

>>
>>> ---
>>>   drivers/of/of_reserved_mem.c | 5 ++++-
>>>   1 file changed, 4 insertions(+), 1 deletion(-)
>> I'm looking for an ack from Marek on this.
>
>Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>

Thank you for your Ack
>
>Best regards
>--
>Marek Szyprowski, PhD
>Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
