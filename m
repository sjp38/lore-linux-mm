Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 19BAB6B0070
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 03:45:18 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id lz20so4352055obb.14
        for <linux-mm@kvack.org>; Sat, 17 Nov 2012 00:45:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1352826834-11774-1-git-send-email-mingo@kernel.org>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org>
Date: Sat, 17 Nov 2012 16:45:17 +0800
Message-ID: <CAGjg+kGKagtybwb+dTW8QVyhrjrQmfyPM9tv8asFQsP=z39suw@mail.gmail.com>
Subject: Re: [PATCH 00/31] Latest numa/core patches, v15
From: Alex Shi <lkml.alex@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

had caught a ops on my 2 sockets SNB EP server. but can not reproduce it.
send out as a reminder:
on tip/master, head : a7b7a8ad4476bb641c8455a4e0d7d0fd3eb86f90

Oops: 0000 [#1] SMP
[   21.967103] Modules linked in: iTCO_wdt iTCO_vendor_support
i2c_i801 igb microcode lpc_ich ioatdma i2c_core joydev mfd_core hed
dca ipv6 isci libsas scsi_transport_sas
[   21.967109] CPU 7
[   21.967109] Pid: 754, comm: systemd-readahe Not tainted
3.7.0-rc5-tip+ #20 Intel Corporation S2600CP/S2600CP
[   21.967115] RIP: 0010:[<ffffffff8114987f>]  [<ffffffff8114987f>]
__fd_install+0x2d/0x4f
[   21.967117] RSP: 0018:ffff8808187f7de8  EFLAGS: 00010246
[   21.967118] RAX: ffff881018bfb700 RBX: ffff88081c2f5d80 RCX: ffff880818dfc620
[   21.967120] RDX: ffff881019b10000 RSI: 00000000ffffffff RDI: ffff88081c2f5e00
[   21.967122] RBP: ffff8808187f7e08 R08: ffff88101b37e008 R09: ffffffff811644a6
[   21.967123] R10: ffff880818005e00 R11: ffff880818005e00 R12: 00000000ffffffff
[   21.967125] R13: 0000000000000000 R14: 00000000fffffff2 R15: 0000000000000000
[   21.967128] FS:  00007ffa79ead7e0(0000) GS:ffff88081fce0000(0000)
knlGS:0000000000000000
[   21.967130] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   21.967131] CR2: ffff881819b0fff8 CR3: 000000081be54000 CR4: 00000000000407e0
[   21.967133] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   21.967135] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   21.967137] Process systemd-readahe (pid: 754, threadinfo
ffff8808187f6000, task ffff880818dfc620)
[   21.967138] Stack:
[   21.967145]  ffff880818005e00 ffff88101b37e000 ffff880818005e00
00007fff57d29378
[   21.967150]  ffff8808187f7e18 ffffffff811498c6 ffff8808187f7ed8
ffffffff81167a7c
[   21.967155]  ffff880818dfc620 ffff880818dfc620 ffff880818004d00
ffff880818005e40
[   21.967156] Call Trace:
[   21.967162]  [<ffffffff811498c6>] fd_install+0x25/0x27
[   21.967168]  [<ffffffff81167a7c>] fanotify_read+0x38d/0x475
[   21.967176]  [<ffffffff8106716e>] ? remove_wait_queue+0x3a/0x3a
[   21.967181]  [<ffffffff81133e21>] vfs_read+0xa9/0xf0
[   21.967186]  [<ffffffff811422cb>] ? poll_select_set_timeout+0x63/0x81
[   21.967189]  [<ffffffff81133ec1>] sys_read+0x59/0x7e
[   21.967195]  [<ffffffff814bd699>] system_call_fastpath+0x16/0x1b
[   21.967222] Code: 66 66 90 55 48 89 e5 41 55 49 89 d5 41 54 41 89
f4 53 48 89 fb 48 8d bf 80 00 00 00 41 53 e8 69 ce 36 00 48 8b 43 08
48 8b 50 08 <4a> 83 3c e2 00 74 02 0f 0b 48 8b 40 08 4e 89 2c e0 66 83
83 80
[   21.967226] RIP  [<ffffffff8114987f>] __fd_install+0x2d/0x4f
[   21.967227]  RSP <ffff8808187f7de8>
[   21.967228] CR2: ffff881819b0fff8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
