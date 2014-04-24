Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0A25E6B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 22:52:33 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so1460448pbc.1
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 19:52:33 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id gr5si1714483pac.442.2014.04.23.19.52.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 19:52:33 -0700 (PDT)
Message-ID: <53587C48.8080103@huawei.com>
Date: Thu, 24 Apr 2014 10:51:52 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] ARM: mm: support big-endian page tables
References: <534F9F79.9050503@huawei.com> <87ob00wau2.fsf@approximate.cambridge.arm.com> <20140423132033.GE5649@arm.com>
In-Reply-To: <20140423132033.GE5649@arm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, Ben Dooks <ben.dooks@codethink.co.uk>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Li Zefan <lizefan@huawei.com>, Wang Nan <wangnan0@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 2014/4/23 21:20, Will Deacon wrote:

> Hi Jianguo,
> 
> On Thu, Apr 17, 2014 at 10:43:01AM +0100, Marc Zyngier wrote:
>> On Thu, Apr 17 2014 at 10:31:37 am BST, Jianguo Wu <wujianguo@huawei.com> wrote:
>>> When enable LPAE and big-endian in a hisilicon board, while specify
>>> mem=384M mem=512M@7680M, will get bad page state:
>>>
>>> Freeing unused kernel memory: 180K (c0466000 - c0493000)
>>> BUG: Bad page state in process init  pfn:fa442
>>> page:c7749840 count:0 mapcount:-1 mapping:  (null) index:0x0
>>> page flags: 0x40000400(reserved)
>>> Modules linked in:
>>> CPU: 0 PID: 1 Comm: init Not tainted 3.10.27+ #66
>>> [<c000f5f0>] (unwind_backtrace+0x0/0x11c) from [<c000cbc4>] (show_stack+0x10/0x14)
>>> [<c000cbc4>] (show_stack+0x10/0x14) from [<c009e448>] (bad_page+0xd4/0x104)
>>> [<c009e448>] (bad_page+0xd4/0x104) from [<c009e520>] (free_pages_prepare+0xa8/0x14c)
>>> [<c009e520>] (free_pages_prepare+0xa8/0x14c) from [<c009f8ec>] (free_hot_cold_page+0x18/0xf0)
>>> [<c009f8ec>] (free_hot_cold_page+0x18/0xf0) from [<c00b5444>] (handle_pte_fault+0xcf4/0xdc8)
>>> [<c00b5444>] (handle_pte_fault+0xcf4/0xdc8) from [<c00b6458>] (handle_mm_fault+0xf4/0x120)
>>> [<c00b6458>] (handle_mm_fault+0xf4/0x120) from [<c0013754>] (do_page_fault+0xfc/0x354)
>>> [<c0013754>] (do_page_fault+0xfc/0x354) from [<c0008400>] (do_DataAbort+0x2c/0x90)
>>> [<c0008400>] (do_DataAbort+0x2c/0x90) from [<c0008fb4>] (__dabt_usr+0x34/0x40)
> 
> 
> [...]
> 
> Please can you put this into Russell's patch system? You can also add my
> ack:
> 
>   Acked-by: Will Deacon <will.deacon@arm.com>
> 
> You should also CC stable <stable@vger.kernel.org> in the commit log.
> 

Hi Will,
I have submit to http://www.arm.linux.org.uk/developer/patches/viewpatch.php?id=8037/1.

Thanks,
Jianguo Wu.

> Cheers,
> 
> Will
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
