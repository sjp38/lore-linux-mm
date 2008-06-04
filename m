Date: Wed, 4 Jun 2008 23:46:22 +0900
From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: Collision of SLUB unique ID
Message-Id: <20080604234622.4b73289c.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: yoichi_yuasa@tripeaks.co.jp, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm testing SLUB on Cobalt(MIPS machine).
I got the following error messages at the boot time.

The Cobalt's ARCH_KMALLOC_MINALIGN is 128.
At this time, kmalloc-192 unique ID has collided with kmalloc-256.

kobject_add_internal failed for :0000256 with -EEXIST, don't try to register things with the same name in the same directory.
Call Trace:
[<80086f34>] dump_stack+0x8/0x34
[<801d4dbc>] kobject_add_internal+0x20c/0x214
[<801d51cc>] kobject_init_and_add+0x40/0x58
[<800fdbfc>] sysfs_slab_add+0x148/0x204
[<803ac1b0>] slab_sysfs_init+0x80/0x158
[<803a46c4>] kernel_init+0xa4/0x2e4
[<800830dc>] kernel_thread_helper+0x10/0x18

Bad page state in process 'swapper'
page:81001d00 flags:0x00000400 mapping:00000000 mapcount:0 count:0
Trying to fix it up, but a reboot is needed
Backtrace:
Call Trace:
[<80086f34>] dump_stack+0x8/0x34
[<800dadc4>] bad_page+0x74/0xb4
[<800db874>] free_hot_cold_page+0x21c/0x22c
[<801d4aa8>] kobject_release+0x58/0xb4
[<801d5b38>] kref_put+0x68/0xac
[<800fdc0c>] sysfs_slab_add+0x158/0x204
[<803ac1b0>] slab_sysfs_init+0x80/0x158
[<803a46c4>] kernel_init+0xa4/0x2e4
[<800830dc>] kernel_thread_helper+0x10/0x18

SLUB: Unable to add boot slab kmalloc-192 to sysfs


Thanks,

Yoichi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
