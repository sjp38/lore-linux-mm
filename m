Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E9FFA6B013F
	for <linux-mm@kvack.org>; Thu,  8 May 2014 22:39:20 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so3100807pdj.10
        for <linux-mm@kvack.org>; Thu, 08 May 2014 19:39:20 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id tx10si270436pac.112.2014.05.08.19.39.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 May 2014 19:39:20 -0700 (PDT)
Message-ID: <536C3FC7.2030402@huawei.com>
Date: Fri, 9 May 2014 10:39:03 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Kernel panic related with OOM-killer
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Wang Nan <wangnan0@huawei.com>

Hi,

We have a question about Kernel panic related with OOM-killer on an ARM-A15 board.
But it reproduced randomly.

Does anyone has some issues like this or some suggestion?
Thank you so much.

The Logs when kernel panic was occurred as follows.

[59313.549221] Killed process 15479 (server) total-vm:9984kB, anon-rss:68kB, file-rss:0kB
[59318.531080] Out of memory: Kill process 15485 (server) score 0 or sacrifice child
[59318.618689] Killed process 15485 (server) total-vm:9984kB, anon-rss:68kB, file-rss:0kB
[59321.839161] Out of memory: Kill process 1339 (portmap) score 0 or sacrifice child
[59321.926735] Killed process 1339 (portmap) total-vm:1732kB, anon-rss:64kB, file-rss:0kB
[59327.626410] Kernel panic - not syncing: Out of memory and no killable processes...
[59327.626410]
[59327.732711] CPU: 15 PID: 28026 Comm: rmap-test Tainted: G           O 3.10.37 #1
[59327.821217] [<c0011a6c>] (unwind_backtrace+0x0/0x12c) from [<c000d0b0>] (show_stack+0x20/0x24)
[59327.924275] [<c000d0b0>] (show_stack+0x20/0x24) from [<c0310f74>] (dump_stack+0x20/0x28)
[59328.021090] [<c0310f74>] (dump_stack+0x20/0x28) from [<c030e2f0>] (panic+0x98/0x1fc)
[59328.113748] [<c030e2f0>] (panic+0x98/0x1fc) from [<c00c2d20>] (out_of_memory+0x23c/0x2b4)
[59328.211609] [<c00c2d20>] (out_of_memory+0x23c/0x2b4) from [<c00c6ba0>] (__alloc_pages_nodemask+0x604/0x7e8)
[59328.328207] [<c00c6ba0>] (__alloc_pages_nodemask+0x604/0x7e8) from [<c00df164>] (__pte_alloc+0x30/0x16c)
[59328.441685] [<c00df164>] (__pte_alloc+0x30/0x16c) from [<c00e2ba4>] (handle_mm_fault+0x158/0x184)
[59328.547872] [<c00e2ba4>] (handle_mm_fault+0x158/0x184) from [<c03164c8>] (do_page_fault+0x150/0x3ac)
[59328.657181] [<c03164c8>] (do_page_fault+0x150/0x3ac) from [<c0316750>] (do_translation_fault+0x2c/0x100)
[59328.770658] [<c0316750>] (do_translation_fault+0x2c/0x100) from [<c000842c>] (do_DataAbort+0x3c/0xa0)
[59328.881012] [<c000842c>] (do_DataAbort+0x3c/0xa0) from [<c0314c78>] (__dabt_usr+0x38/0x40)
[59328.979907] Exception stack(0xc1b73fb0 to 0xc1b73ff8)
[59329.040289] 3fa0:                                     b4d9f000 00000000 00012a00 00000064
[59329.138150] 3fc0: 00000000 00000000 b4d9f000 000129d4 00012a24 00000001 00000000 00000051
[59329.236011] 3fe0: 00000000 be8b9608 00009198 00008dc0 60000010 ffffffff
[59329.315145] CPU3: stopping
[59329.347408] CPU: 3 PID: 28191 Comm: rmap-test Tainted: G           O 3.10.37 #1
[59329.434869] [<c0011a6c>] (unwind_backtrace+0x0/0x12c) from [<c000d0b0>] (show_stack+0x20/0x24)
[59329.537927] [<c000d0b0>] (show_stack+0x20/0x24) from [<c0310f74>] (dump_stack+0x20/0x28)
[59329.634745] [<c0310f74>] (dump_stack+0x20/0x28) from [<c000f450>] (handle_IPI+0xd0/0x134)
[59329.732604] [<c000f450>] (handle_IPI+0xd0/0x134) from [<c00085d0>] (gic_handle_irq+0x68/0x70)
[59329.834628] [<c00085d0>] (gic_handle_irq+0x68/0x70) from [<c0314b40>] (__irq_svc+0x40/0x50)
[59329.934564] Exception stack(0xc32d5a28 to 0xc32d5a70)
[59329.994948] 5a20:                   00000001 0000000a 00000000 00000003 c32d4000 00000002
[59330.092809] 5a40: c04f50b4 c32d5b5c 00000000 c05212c0 3fb23f7c c32d5abc c32d5a70 c32d5a70
[59330.190666] 5a60: c0026c1c c0027e44 60000113 ffffffff
[59330.251057] [<c0314b40>] (__irq_svc+0x40/0x50) from [<c0027e44>] (__do_softirq+0x94/0x26c)
[59330.349955] [<c0027e44>] (__do_softirq+0x94/0x26c) from [<c00280d0>] (do_softirq+0x54/0x60)
[59330.449896] [<c00280d0>] (do_softirq+0x54/0x60) from [<c002836c>] (irq_exit+0x84/0x98)
[59330.465136] SMP: failed to stop secondary CPUs
[59330.597728] [<c002836c>] (irq_exit+0x84/0x98) from [<c0009ee4>] (handle_IRQ+0x78/0x9c)
[59330.692465] [<c0009ee4>] (handle_IRQ+0x78/0x9c) from [<c00085b4>] (gic_handle_irq+0x4c/0x70)
[59330.793449] [<c00085b4>] (gic_handle_irq+0x4c/0x70) from [<c0314b40>] (__irq_svc+0x40/0x50)
[59330.893385] Exception stack(0xc32d5b28 to 0xc32d5b70)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
