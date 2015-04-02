Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id DBFBB6B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 09:04:59 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so8938467pdb.0
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 06:04:59 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id j13si7432279pdk.226.2015.04.02.06.04.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 02 Apr 2015 06:04:58 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NM600GJRKIP66A0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 02 Apr 2015 14:08:50 +0100 (BST)
Message-id: <551D3E73.9070405@partner.samsung.com>
Date: Thu, 02 Apr 2015 16:04:51 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: cma: add trace events for CMA allocations and freeings
References: <1427895103-9431-1-git-send-email-s.strogin@partner.samsung.com>
 <20150402073340.GA13158@js1304-P5Q-DELUXE>
In-reply-to: <20150402073340.GA13158@js1304-P5Q-DELUXE>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Sasha Levin <sasha.levin@oracle.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gioh.kim@lge.com, stefan.strogin@gmail.com

Hello Joonsoo,

On 02/04/15 10:33, Joonsoo Kim wrote:
> Hello,
> 
> On Wed, Apr 01, 2015 at 04:31:43PM +0300, Stefan Strogin wrote:
>> Add trace events for cma_alloc() and cma_release().
>>
>> The cma_alloc tracepoint is used both for successful and failed allocations,
>> in case of allocation failure pfn=-1UL is stored and printed.
>>
>> Signed-off-by: Stefan Strogin <stefan.strogin@gmail.com>
>> ---
>>
>> Took out from the patch set "mm: cma: add some debug information for CMA" v4
>> (http://thread.gmane.org/gmane.linux.kernel.mm/129903) because of probable
>> uselessness of the rest of the patches.
> 
> I think that patch 5/5 in previous submission is handy and
> simple to merge. Although we can calculate it by using bitmap,
> it would be good to get that information(used size and maxchunk size)
> directly.

Well, then I can send the patch 5/5 once more, this time singly.

> 
>> @@ -414,6 +416,8 @@ struct page *cma_alloc(struct cma *cma, unsigned int count, unsigned int align)
>>  		start = bitmap_no + mask + 1;
>>  	}
>>  
>> +	trace_cma_alloc(page ? pfn : -1UL, page, count);
>> +
> 
> I think that tracing align is also useful.
> Is there any reason not to include it?

In our case (DMA) alignment is easily calculated from the allocation
size and CONFIG_CMA_ALIGNMENT. But I think you're right, e.g. it may be
not so obvious on powerpc kvm? Anyway it won't be a shortcoming if we
trace 'align' too.

> 
> Thanks.

Thank you for the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
