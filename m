Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5486B006C
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 08:13:59 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id lf10so2926121pab.18
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 05:13:59 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id d7si5027115pdn.206.2014.10.27.05.13.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Oct 2014 05:13:58 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NE3000PHRFW1A30@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Oct 2014 12:16:44 +0000 (GMT)
Message-id: <544E3702.8060508@samsung.com>
Date: Mon, 27 Oct 2014 13:13:54 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm, cma: make parameters order consistent in func
 declaration and definition
References: <000201cfef6f$c5422b10$4fc68130$%yang@samsung.com>
 <xa1td29h2zlo.fsf@mina86.com>
In-reply-to: <xa1td29h2zlo.fsf@mina86.com>
Content-type: text/plain; charset=utf-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Weijie Yang <weijie.yang@samsung.com>
Cc: iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

Hello,

On 2014-10-24 18:37, Michal Nazarewicz wrote:
> On Fri, Oct 24 2014, Weijie Yang <weijie.yang@samsung.com> wrote:
>> In the current code, the base and size parameters order is not consistent
>> in functions declaration and definition. If someone calls these functions
>> according to the declaration parameters order in cma.h, he will run into
>> some bug and it's hard to find the reason.
>>
>> This patch makes the parameters order consistent in functions declaration
>> and definition.
>>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>

Applied to my fixes-for-v3.18 branch.

>> ---
>>   include/linux/cma.h |    8 ++++----
>>   1 files changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/cma.h b/include/linux/cma.h
>> index 0430ed0..a93438b 100644
>> --- a/include/linux/cma.h
>> +++ b/include/linux/cma.h
>> @@ -18,12 +18,12 @@ struct cma;
>>   extern phys_addr_t cma_get_base(struct cma *cma);
>>   extern unsigned long cma_get_size(struct cma *cma);
>>   
>> -extern int __init cma_declare_contiguous(phys_addr_t size,
>> -			phys_addr_t base, phys_addr_t limit,
>> +extern int __init cma_declare_contiguous(phys_addr_t base,
>> +			phys_addr_t size, phys_addr_t limit,
>>   			phys_addr_t alignment, unsigned int order_per_bit,
>>   			bool fixed, struct cma **res_cma);
>> -extern int cma_init_reserved_mem(phys_addr_t size,
>> -					phys_addr_t base, int order_per_bit,
>> +extern int cma_init_reserved_mem(phys_addr_t base,
>> +					phys_addr_t size, int order_per_bit,
>>   					struct cma **res_cma);
>>   extern struct page *cma_alloc(struct cma *cma, int count, unsigned int align);
>>   extern bool cma_release(struct cma *cma, struct page *pages, int count);
>> -- 
>> 1.7.0.4

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
