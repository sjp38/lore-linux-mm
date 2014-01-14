Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE636B0036
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 09:30:11 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f11so109482yha.35
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 06:30:11 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id j24si1072101yhb.71.2014.01.14.06.30.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 06:30:10 -0800 (PST)
Message-ID: <52D548B1.8000504@ti.com>
Date: Tue, 14 Jan 2014 09:24:49 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 2/2] mm/memblock: Add support for excluded memory areas
References: <1389618217-48166-1-git-send-email-phacht@linux.vnet.ibm.com> <1389618217-48166-3-git-send-email-phacht@linux.vnet.ibm.com> <52D538FD.8010907@ti.com>
In-Reply-To: <52D538FD.8010907@ti.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qiuxishi@huawei.com, dhowells@redhat.com, daeseok.youn@gmail.com, liuj97@gmail.com, yinghai@kernel.org, zhangyanfei@cn.fujitsu.com, tangchen@cn.fujitsu.com

On Tuesday 14 January 2014 08:17 AM, Grygorii Strashko wrote:
> Hi Philipp,
> 
> On 01/13/2014 03:03 PM, Philipp Hachtmann wrote:
>> Add a new memory state "nomap" to memblock. This can be used to truncate
>> the usable memory in the system without forgetting about what is really
>> installed.
> 
> 
> Sorry, but this solution looks a bit complex (and probably wrong - from design point of view))
> if you need just to fix memblock_start_of_DRAM()/memblock_end_of_DRAM() APIs.
> 
> More over, other arches use at least below APIs: 
> - memblock_is_region_memory() !!!
> - for_each_memblock(memory, reg) !!!
> - __next_mem_pfn_range() !!!
> - memblock_phys_mem_size()
> - memblock_mem_size()
> - memblock_start_of_DRAM()
> - memblock_end_of_DRAM()
> with assumption that "memory" regions array have been updated
> when mem block is stolen (no-mapped), as result this change may
> have unpredictable side effects :( if these new APIs
> will be re-used (for ARM arch, as example).
> 
> You can take a look on how ARM is using arm_memblock_steal() - 
> the stolen memory is not accounted any more.
> 
I was also wondering instead of nomap state, the memblock_add/remove()
will do the same trick. arm_memblock_steal() wrapper does achieve
similar functionality of reserving the DRAM without mapping it into
the Linux. Why not just use the same idea ?

Regards,
Santosh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
