Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC986B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 09:47:01 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so19729336pad.10
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 06:47:01 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id c4si11083285pas.96.2014.12.30.06.46.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 30 Dec 2014 06:46:58 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NHE00ECDH92PN20@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 30 Dec 2014 14:51:02 +0000 (GMT)
Message-id: <54A2BADB.4090105@partner.samsung.com>
Date: Tue, 30 Dec 2014 17:46:51 +0300
From: Safonov Dmitry <d.safonov@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 3/3] cma: add functions to get region pages counters
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
 <dfddb08aba9a05e6e7b43e9861ab09b7ac1c89cd.1419602920.git.s.strogin@partner.samsung.com>
 <20141230022625.GA4588@js1304-P5Q-DELUXE> <xa1th9wdtd32.fsf@mina86.com>
In-reply-to: <xa1th9wdtd32.fsf@mina86.com>
Content-type: text/plain; charset=utf-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>


On 12/30/2014 05:41 PM, Michal Nazarewicz wrote:
>> On Fri, Dec 26, 2014 at 05:39:04PM +0300, Stefan I. Strogin wrote:
>>> From: Dmitry Safonov <d.safonov@partner.samsung.com>
>>> @@ -591,6 +621,10 @@ static int s_show(struct seq_file *m, void *p)
>>>   	struct cma_buffer *cmabuf;
>>>   	struct stack_trace trace;
>>>   
>>> +	seq_printf(m, "CMARegion stat: %8lu kB total, %8lu kB used, %8lu kB max contiguous chunk\n\n",
>>> +		   cma_get_size(cma) >> 10,
>>> +		   cma_get_used(cma) >> 10,
>>> +		   cma_get_maxchunk(cma) >> 10);
>>>   	mutex_lock(&cma->list_lock);
>>>   
>>>   	list_for_each_entry(cmabuf, &cma->buffers_list, list) {
> On Tue, Dec 30 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>> How about changing printing format like as meminfo or zoneinfo?
>>
>> CMARegion #
>> Total: XXX
>> Used: YYY
>> MaxContig: ZZZ
> +1.  I was also thinking about this actually.
>
Yeah, I thought about it. Sure.

-- 
Best regards,
Safonov Dmitry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
