Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 27FE49003C8
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 05:59:43 -0400 (EDT)
Received: by oibn4 with SMTP id n4so3016587oib.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 02:59:42 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id r133si447285oib.79.2015.07.14.02.59.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jul 2015 02:59:42 -0700 (PDT)
Message-ID: <55A4DB56.6070504@huawei.com>
Date: Tue, 14 Jul 2015 17:50:14 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [BUG REPORT] OOM Killer is invoked while the system still has
 much memory
References: <6D317A699782EA4DB9A0E6266C9219696CA2B3BC@SZXEMA501-MBX.china.huawei.com> <20150714081521.GA17711@dhcp22.suse.cz> <55A4CB68.5060906@huawei.com> <20150714090025.GA17660@dhcp22.suse.cz> <55A4D300.5030704@huawei.com> <20150714092842.GB17660@dhcp22.suse.cz>
In-Reply-To: <20150714092842.GB17660@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Xuzhichuang <xuzhichuang@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Songjiangtao (mygirlsjt)" <songjiangtao.song@huawei.com>, "Zhangwei (FF)" <zw.zhang@huawei.com>

On 2015/7/14 17:28, Michal Hocko wrote:

> On Tue 14-07-15 17:14:40, Xishi Qiu wrote:
>> On 2015/7/14 17:00, Michal Hocko wrote:
>>
>>> On Tue 14-07-15 16:42:16, Xishi Qiu wrote:
>>>> On 2015/7/14 16:15, Michal Hocko wrote:
>>>>
>>>>> On Tue 14-07-15 07:11:34, Xuzhichuang wrote:
>>> [...]
>>>>>> Jul 10 12:33:03 BMS_CNA04 kernel: [18136514.138968] DMA32: 188513*4kB 29459*8kB 2*16kB 2*32kB 1*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 990396kB
>>>>>
>>>>> Moreover your allocation request was oreder 2 and you do not have much
>>>>> memory there because most of the free memory is in order-0-2.
>>>>>
>>>>
>>>> Hi Michal,
>>>>
>>>> order=2 -> alloc 16kb memory, and DMA32 still has 2*16kB 2*32kB 1*64kB 1*512kB, 
>>>> so you mean this large buddy block was reclaimed during the moment of oom and 
>>>> print, right?
>>>
>>> Not really. Those high order blocks are inaccessible for your GFP_KERNEL
>>> allocation. See __zone_watermark_ok.
>>>
>>
>> I know, some of them are from reserved memory(MIGRATE_RESERVE), right?
> 
> No. The watermark is calculated per order. And you have almost all the
> free memory in the lower orders. From a quick glance it seems that even
> order-1 allocations wouldn't fit into min watermark.

So we can't alloc memory because it doesn't fit the watermark, and
the large buddy blocks maybe from reserved, or maybe not, right?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
