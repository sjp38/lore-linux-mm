Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC4E06B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 03:56:55 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id h144so98047137ita.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 00:56:55 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id ke3si11009200igc.21.2016.05.27.00.56.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 May 2016 00:56:55 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0O7T00G0JSQRCH70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 27 May 2016 08:56:51 +0100 (BST)
Subject: Re: [RESEND][PATCH] drivers: of: of_reserved_mem: fixup the CMA
 alignment not to affect dma-coherent
References: <1464150590-2703-1-git-send-email-jaewon31.kim@samsung.com>
 <CAL_JsqLu+KxXdZseQiRFPr5MG0hSnwnQJpBLg0M5tgO-ap4F=g@mail.gmail.com>
From: Marek Szyprowski <m.szyprowski@samsung.com>
Message-id: <0a1e9e76-9506-a0c3-e3c5-521c7a89bfbc@samsung.com>
Date: Fri, 27 May 2016 09:56:50 +0200
MIME-version: 1.0
In-reply-to: 
 <CAL_JsqLu+KxXdZseQiRFPr5MG0hSnwnQJpBLg0M5tgO-ap4F=g@mail.gmail.com>
Content-type: text/plain; charset=utf-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh+dt@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>
Cc: r64343@freescale.com, Grant Likely <grant.likely@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jaewon31.kim@gmail.com

Hello,


On 2016-05-25 16:38, Rob Herring wrote:
> On Tue, May 24, 2016 at 11:29 PM, Jaewon Kim <jaewon31.kim@samsung.com> wrote:
>> From: Jaewon <jaewon31.kim@samsung.com>
>>
>> There was an alignment mismatch issue for CMA and it was fixed by
>> commit 1cc8e3458b51 ("drivers: of: of_reserved_mem: fixup the alignment with CMA setup").
>> However the way of the commit considers not only dma-contiguous(CMA) but also
>> dma-coherent which has no that requirement.
>>
>> This patch checks more to distinguish dma-contiguous(CMA) from dma-coherent.
>>
>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
> I suppose this needs to go to stable? If so, adding the stable tag and
> kernel version would be nice so I don't have to.
>
>> ---
>>   drivers/of/of_reserved_mem.c | 5 ++++-
>>   1 file changed, 4 insertions(+), 1 deletion(-)
> I'm looking for an ack from Marek on this.

Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
