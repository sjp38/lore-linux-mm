Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id D01726B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 09:20:46 -0400 (EDT)
Received: by mail-yh0-f50.google.com with SMTP id t59so801054yho.23
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 06:20:46 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id o24si1038655yhn.145.2014.04.23.06.20.45
        for <linux-mm@kvack.org>;
        Wed, 23 Apr 2014 06:20:46 -0700 (PDT)
Date: Wed, 23 Apr 2014 14:20:33 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v3] ARM: mm: support big-endian page tables
Message-ID: <20140423132033.GE5649@arm.com>
References: <534F9F79.9050503@huawei.com>
 <87ob00wau2.fsf@approximate.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ob00wau2.fsf@approximate.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: Jianguo Wu <wujianguo@huawei.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, Ben Dooks <ben.dooks@codethink.co.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Li Zefan <lizefan@huawei.com>, Wang Nan <wangnan0@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Jianguo,

On Thu, Apr 17, 2014 at 10:43:01AM +0100, Marc Zyngier wrote:
> On Thu, Apr 17 2014 at 10:31:37 am BST, Jianguo Wu <wujianguo@huawei.com> wrote:
> > When enable LPAE and big-endian in a hisilicon board, while specify
> > mem=384M mem=512M@7680M, will get bad page state:
> >
> > Freeing unused kernel memory: 180K (c0466000 - c0493000)
> > BUG: Bad page state in process init  pfn:fa442
> > page:c7749840 count:0 mapcount:-1 mapping:  (null) index:0x0
> > page flags: 0x40000400(reserved)
> > Modules linked in:
> > CPU: 0 PID: 1 Comm: init Not tainted 3.10.27+ #66
> > [<c000f5f0>] (unwind_backtrace+0x0/0x11c) from [<c000cbc4>] (show_stack+0x10/0x14)
> > [<c000cbc4>] (show_stack+0x10/0x14) from [<c009e448>] (bad_page+0xd4/0x104)
> > [<c009e448>] (bad_page+0xd4/0x104) from [<c009e520>] (free_pages_prepare+0xa8/0x14c)
> > [<c009e520>] (free_pages_prepare+0xa8/0x14c) from [<c009f8ec>] (free_hot_cold_page+0x18/0xf0)
> > [<c009f8ec>] (free_hot_cold_page+0x18/0xf0) from [<c00b5444>] (handle_pte_fault+0xcf4/0xdc8)
> > [<c00b5444>] (handle_pte_fault+0xcf4/0xdc8) from [<c00b6458>] (handle_mm_fault+0xf4/0x120)
> > [<c00b6458>] (handle_mm_fault+0xf4/0x120) from [<c0013754>] (do_page_fault+0xfc/0x354)
> > [<c0013754>] (do_page_fault+0xfc/0x354) from [<c0008400>] (do_DataAbort+0x2c/0x90)
> > [<c0008400>] (do_DataAbort+0x2c/0x90) from [<c0008fb4>] (__dabt_usr+0x34/0x40)


[...]

Please can you put this into Russell's patch system? You can also add my
ack:

  Acked-by: Will Deacon <will.deacon@arm.com>

You should also CC stable <stable@vger.kernel.org> in the commit log.

Cheers,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
