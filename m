Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0476B028C
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 20:40:35 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z24so4691260pgu.20
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 17:40:35 -0800 (PST)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id u80si33130689pfd.169.2018.01.01.17.40.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jan 2018 17:40:34 -0800 (PST)
Subject: Re: [RFC] does ioremap() cause memory leak?
References: <5A3B76EE.8020001@huawei.com> <5A3DEA6A.9080709@huawei.com>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <e25b1da2-14fb-eeec-1a76-1756011535bb@huawei.com>
Date: Tue, 2 Jan 2018 09:39:47 +0800
MIME-Version: 1.0
In-Reply-To: <5A3DEA6A.9080709@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Toshi Kani <toshi.kani@hp.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, lious.lilei@hisilicon.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LinuxArm <linuxarm@huawei.com>

On 2017/12/23 13:32, Xishi Qiu wrote:
> On 2017/12/21 16:55, Xishi Qiu wrote:
> 
>> When we use iounmap() to free the mapping, it calls unmap_vmap_area() to clear page table,
>> but do not free the memory of page table, right?
>>
>> So when use ioremap() to mapping another area(incluce the area before), it may use
>> large mapping(e.g. ioremap_pmd_enabled()), so the original page table memory(e.g. pte memory)
>> will be lost, it cause memory leak, right?
> 
>  
> 
> So I have two questions for this scene.
> 
> 1. When the same virtual address allocated from ioremap, first is 4K size, second is 2M size, if Kernel would leak memory.
> 
> 2. Kernel modifies the old invalid 4K pagetable to 2M, but doesn`t follow the ARM break-before-make flow, CPU maybe get the old invalid 4K pagetable information, then Kernel would panic.

I sent a RFC patch for this one [1].

[1]: https://patchwork.kernel.org/patch/10134581/

Thanks
Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
