Message-ID: <41177F20.5070308@us.ibm.com>
Date: Mon, 09 Aug 2004 06:41:52 -0700
From: Janet Morgan <janetmor@us.ibm.com>
MIME-Version: 1.0
Subject: 2.6.8-rc3-mm2:  Debug: sleeping function called from invalid context
 at mm/mempool.c:197
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I see the msg below while running on 2.6.8-rc3-mm2, but not on the plain 
rc3 tree;
ditto for rc1-mm1 vs rc1, which is as far back as I've gone so far.

I'm using QLogic QLA2200 adapters and both ext2/ext3 filesystems.  
The problem is very recreatable for me -- I pretty much just open a 
large file on one
of the qlogic-attached devices.

I tried backing out bk-scsi.patch for the heck of it, but I still see 
the problem.

Aug  9 10:33:43 elm3b81 kernel: Debug: sleeping function called from 
invalid context at mm/mempool.c:197
Aug  9 10:33:43 elm3b81 kernel: in_atomic():1, irqs_disabled():0
Aug  9 10:33:43 elm3b81 kernel:  [<c0105f4e>] dump_stack+0x1e/0x30
Aug  9 10:33:43 elm3b81 kernel:  [<c011d2a9>] __might_sleep+0x99/0xb0
Aug  9 10:33:43 elm3b81 kernel:  [<c013dadb>] mempool_alloc+0x14b/0x150
Aug  9 10:33:43 elm3b81 kernel:  [<f8a6cb8c>] 
qla2x00_get_new_sp+0x1c/0x30 [qla2xxx]
Aug  9 10:33:43 elm3b81 kernel:  [<f8a6868a>] 
qla2x00_queuecommand+0x3a/0x6a0 [qla2xxx]
Aug  9 10:33:43 elm3b81 kernel:  [<c036f941>] scsi_dispatch_cmd+0x141/0x1e0
Aug  9 10:33:43 elm3b81 kernel:  [<c0374c9f>] scsi_request_fn+0x1ef/0x3d0
Aug  9 10:33:43 elm3b81 kernel:  [<c0333b82>] blk_run_queue+0x32/0x50
Aug  9 10:33:43 elm3b81 kernel:  [<c03740f0>] scsi_end_request+0xd0/0xf0
Aug  9 10:33:43 elm3b81 kernel:  [<c0374404>] scsi_io_completion+0x134/0x440
Aug  9 10:33:43 elm3b81 kernel:  [<c0398d9f>] sd_rw_intr+0x5f/0x280
Aug  9 10:33:43 elm3b81 kernel:  [<c036fd63>] scsi_finish_command+0x73/0xb0
Aug  9 10:33:43 elm3b81 kernel:  [<c036fc8b>] scsi_softirq+0xab/0xd0
Aug  9 10:33:43 elm3b81 kernel:  [<c012427c>] __do_softirq+0xbc/0xd0
Aug  9 10:33:43 elm3b81 kernel:  [<c01242c5>] do_softirq+0x35/0x40
Aug  9 10:33:43 elm3b81 kernel:  [<c0107b47>] do_IRQ+0x107/0x130
Aug  9 10:33:43 elm3b81 kernel:  [<c0105a90>] common_interrupt+0x18/0x20

Thanks,
-Janet


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
