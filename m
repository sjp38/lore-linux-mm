Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C81E6B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 02:55:26 -0500 (EST)
Date: Fri, 18 Nov 2011 08:55:21 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111118075521.GB1615@x4.trippels.de>
References: <20111118072519.GA1615@x4.trippels.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111118072519.GA1615@x4.trippels.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Alex Shi <alex.shi@intel.com>, netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>

On 2011.11.18 at 08:25 +0100, Markus Trippelsdorf wrote:
> This happend during boot this morning:
> 
> Nov 18 07:57:12 x4 kernel: XFS (sdb2): Ending clean mount
> Nov 18 07:57:12 x4 kernel: VFS: Mounted root (xfs filesystem) readonly on device 8:18.
> Nov 18 07:57:12 x4 kernel: devtmpfs: mounted
> Nov 18 07:57:12 x4 kernel: Freeing unused kernel memory: 436k freed
> Nov 18 07:57:12 x4 kernel: Write protecting the kernel read-only data: 8192k
> Nov 18 07:57:12 x4 kernel: Freeing unused kernel memory: 1220k freed
> Nov 18 07:57:12 x4 kernel: Freeing unused kernel memory: 132k freed
> Nov 18 07:57:12 x4 kernel: XFS (sda): Mounting Filesystem
> Nov 18 07:57:12 x4 kernel: XFS (sda): Ending clean mount
> Nov 18 07:57:12 x4 kernel: ATL1E 0000:02:00.0: irq 40 for MSI/MSI-X
> Nov 18 07:57:12 x4 kernel: ATL1E 0000:02:00.0: eth0: NIC Link is Up <100 Mbps Full Duplex>
> Nov 18 07:57:12 x4 kernel: ATL1E 0000:02:00.0: eth0: NIC Link is Up <100 Mbps Full Duplex>
> Nov 18 07:57:13 x4 kernel: Adding 2097148k swap on /var/tmp/swap/swapfile.  Priority:-1 extents:2 across:2634672k
> Nov 18 07:57:16 x4 kernel: ------------[ cut here ]------------
> Nov 18 07:57:16 x4 kernel: WARNING: at mm/slub.c:3357 ksize+0xa5/0xb0()
> Nov 18 07:57:16 x4 kernel: Hardware name: System Product Name
> Nov 18 07:57:16 x4 kernel: Pid: 1539, comm: wmii Not tainted 3.2.0-rc2-00057-ga9098b3-dirty #60
> Nov 18 07:57:16 x4 kernel: Call Trace:                                                                                                               Nov 18 07:57:16 x4 kernel: [<ffffffff8106cb75>] warn_slowpath_common+0x75/0xb0
> Nov 18 07:57:16 x4 kernel: [<ffffffff8106cc75>] warn_slowpath_null+0x15/0x20
> Nov 18 07:57:16 x4 kernel: [<ffffffff81103985>] ksize+0xa5/0xb0
> Nov 18 07:57:16 x4 kernel: [<ffffffff8141e3ee>] __alloc_skb+0x7e/0x210
> Nov 18 07:57:16 x4 kernel: [<ffffffff8141b75e>] sock_alloc_send_pskb+0x1be/0x300
> Nov 18 07:57:16 x4 kernel: [<ffffffff8141a5d2>] ? sock_wfree+0x52/0x60                                                                               Nov 18 07:57:16 x4 kernel: [<ffffffff8141b8b0>] sock_alloc_send_skb+0x10/0x20                                                                        Nov 18 07:57:16 x4 kernel: [<ffffffff814a3c61>] unix_stream_sendmsg+0x261/0x420
> Nov 18 07:57:16 x4 kernel: [<ffffffff814176ff>] sock_aio_write+0xdf/0x100                                                                            Nov 18 07:57:16 x4 kernel: [<ffffffff81417620>] ? sock_aio_read+0x110/0x110
> Nov 18 07:57:16 x4 kernel: [<ffffffff8110b6ca>] do_sync_readv_writev+0xca/0x110
> Nov 18 07:57:16 x4 kernel: [<ffffffff8110b7fb>] ? rw_copy_check_uvector+0x6b/0x130
> Nov 18 07:57:16 x4 kernel: [<ffffffff8110a8a6>] ? do_sync_read+0xd6/0x110                                                                            Nov 18 07:57:16 x4 kernel: [<ffffffff8110b996>] do_readv_writev+0xd6/0x1e0
> Nov 18 07:57:16 x4 kernel: [<ffffffff8110bb20>] vfs_writev+0x30/0x60                                                                                 Nov 18 07:57:16 x4 kernel: [<ffffffff8110bc25>] sys_writev+0x45/0x90
> Nov 18 07:57:16 x4 kernel: [<ffffffff8111d8d1>] ? sys_poll+0x71/0x110
> Nov 18 07:57:16 x4 kernel: [<ffffffff814ca5fb>] system_call_fastpath+0x16/0x1b
> Nov 18 07:57:16 x4 kernel: ---[ end trace 320a3cfbcb373e9a ]---
> Nov 18 07:57:16 x4 kernel: ------------[ cut here ]------------
> Nov 18 07:57:16 x4 kernel: kernel BUG at mm/slub.c:3413!
> Nov 18 07:57:16 x4 kernel: invalid opcode: 0000 [#1] PREEMPT SMP
> Nov 18 07:57:16 x4 kernel: CPU 1
> Nov 18 07:57:16 x4 kernel: Pid: 1500, comm: X Tainted: G        W    3.2.0-rc2-00057-ga9098b3-dirty #60 System manufacturer System Product Name/M4A78T-E
> Nov 18 07:57:16 x4 kernel: RIP: 0010:[<ffffffff81103ac1>]  [<ffffffff81103ac1>] kfree+0x131/0x140
> Nov 18 07:57:16 x4 kernel: RSP: 0018:ffff88020fbc1b88  EFLAGS: 00010246
> Nov 18 07:57:16 x4 kernel: RAX: 4000000000000000 RBX: ffff880200000000 RCX: 0000000000000304
> Nov 18 07:57:16 x4 kernel: RDX: ffffffff7fffffff RSI: 0000000000000282 RDI: ffff880200000000
> Nov 18 07:57:16 x4 kernel: RBP: ffff88020fbc1ba8 R08: 0000000000000304 R09: ffffea0008000000
> Nov 18 07:57:16 x4 kernel: R10: 00000000005d6ba0 R11: 0000000000003246 R12: ffff880213570700
> Nov 18 07:57:16 x4 kernel: R13: ffffffff8141e8c0 R14: ffff880213570700 R15: ffff880216bba3a0
> Nov 18 07:57:16 x4 kernel: FS:  00007fdc1da79880(0000) GS:ffff88021fc80000(0000) knlGS:0000000000000000
> Nov 18 07:57:16 x4 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> Nov 18 07:57:16 x4 kernel: CR2: 0000000001b39a98 CR3: 000000020fbfc000 CR4: 00000000000006e0
> Nov 18 07:57:16 x4 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Nov 18 07:57:16 x4 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Nov 18 07:57:16 x4 kernel: Process X (pid: 1500, threadinfo ffff88020fbc0000, task ffff880216bba3a0)
> Nov 18 07:57:16 x4 kernel: Stack:
> Nov 18 07:57:16 x4 kernel: 0000000000000000 ffff880213570700 ffff880213570700 0000000000000000
> Nov 18 07:57:16 x4 kernel: ffff88020fbc1bc8 ffffffff8141e8c0 ffff880213570700 ffff880213570700
> Nov 18 07:57:16 x4 kernel: ffff88020fbc1be8 ffffffff8141e8e9 ffff880200000000 ffff880213570700
> Nov 18 07:57:16 x4 kernel: Call Trace:
> Nov 18 07:57:16 x4 kernel: [<ffffffff8141e8c0>] skb_release_data+0xf0/0x100
> Nov 18 07:57:16 x4 kernel: [<ffffffff8141e8e9>] skb_release_all+0x19/0x20
> Nov 18 07:57:16 x4 kernel: [<ffffffff8141e901>] __kfree_skb+0x11/0xa0
> Nov 18 07:57:16 x4 kernel: [<ffffffff8141e9b6>] consume_skb+0x26/0xa0
> Nov 18 07:57:16 x4 kernel: [<ffffffff814a5614>] unix_stream_recvmsg+0x2c4/0x790
> Nov 18 07:57:16 x4 kernel: [<ffffffff8111c1c0>] ? __pollwait+0xf0/0xf0
> Nov 18 07:57:16 x4 kernel: [<ffffffff814175f4>] sock_aio_read+0xe4/0x110
> Nov 18 07:57:16 x4 kernel: [<ffffffff8110a8a6>] do_sync_read+0xd6/0x110
> Nov 18 07:57:16 x4 kernel: [<ffffffff8108fa64>] ? enqueue_hrtimer+0x24/0xc0
> Nov 18 07:57:16 x4 kernel: [<ffffffff81090303>] ? hrtimer_start+0x13/0x20
> Nov 18 07:57:16 x4 kernel: [<ffffffff810714ac>] ? do_setitimer+0x1bc/0x240
> Nov 18 07:57:16 x4 kernel: [<ffffffff8110b095>] vfs_read+0x135/0x160
> Nov 18 07:57:16 x4 kernel: [<ffffffff8110b375>] sys_read+0x45/0x90
> Nov 18 07:57:16 x4 kernel: [<ffffffff814ca5fb>] system_call_fastpath+0x16/0x1b
> Nov 18 07:57:16 x4 kernel: Code: e9 3d ff ff ff 48 89 da 4c 89 ce e8 51 fe 3b 00 e9 77 ff ff ff 49 f7 01 00 c0 00 00 74 0d 4c 89 cf e8 64 24 fd ff e9 61 ff ff ff <0f> 0b 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 53 48
> Nov 18 07:57:16 x4 kernel: RIP  [<ffffffff81103ac1>] kfree+0x131/0x140
> Nov 18 07:57:16 x4 kernel: RSP <ffff88020fbc1b88>
> Nov 18 07:57:16 x4 kernel: ---[ end trace 320a3cfbcb373e9b ]---
> Nov 18 08:01:30 x4 kernel: SysRq : Emergency Sync
> Nov 18 08:01:30 x4 kernel: Emergency Sync complete
> 
> The dirty flag comes from a bunch of unrelated xfs patches from Christoph, that
> I'm testing right now.
> 
> Please also see my previous post: http://thread.gmane.org/gmane.linux.kernel/1215023
> It looks like something is scribbling over memory.
> 
> This machine uses ECC, so bit-flips should be impossible.

CC'ing netdev@vger.kernel.org and Eric Dumazet.

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
