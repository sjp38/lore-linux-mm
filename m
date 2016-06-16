Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 83E116B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:46:57 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 5so96913902ioy.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 01:46:57 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id z9si7123401pau.40.2016.06.16.01.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 01:46:56 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id ts6so3317771pac.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 01:46:56 -0700 (PDT)
Date: Thu, 16 Jun 2016 17:46:57 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [next-20160615] kernel BUG at mm/rmap.c:1251!
Message-ID: <20160616084656.GB432@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello,

[..]
[  272.687656] vma ffff8800b855a5a0 start 00007f3576d58000 end 00007f3576f66000
               next ffff8800b977d2c0 prev ffff8800bdfb1860 mm ffff8801315ff200
               prot 8000000000000025 anon_vma ffff8800b7e583b0 vm_ops           (null)
               pgoff 7f3576d58 file           (null) private_data           (null)
               flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
[  272.691793] ------------[ cut here ]------------
[  272.692820] kernel BUG at mm/rmap.c:1251!
[  272.693843] invalid opcode: 0000 [#1] PREEMPT SMP
[  272.694858] Modules linked in: snd_hda_codec_realtek snd_hda_codec_generic mousedev snd_hda_intel snd_hda_codec snd_hda_core coretemp hwmon snd_pcm r8169 snd_timer crc32c_intel snd mii i2c_i801 soundcore lpc_ich acpi_cpufreq mfd_core processor sch_fq_codel hid_generic usbhid hid sd_mod ahci libahci libata ehci_pci ehci_hcd scsi_mod usbcore usb_common
[  272.697061] CPU: 2 PID: 38 Comm: khugepaged Not tainted 4.7.0-rc3-next-20160615-dbg-00005-gfd11984-dirty #493
[  272.699208] task: ffff88013332a980 ti: ffff880133348000 task.ti: ffff880133348000
[  272.700280] RIP: 0010:[<ffffffff810f67ad>]  [<ffffffff810f67ad>] page_add_new_anon_rmap+0x68/0x136
[  272.701359] RSP: 0000:ffff88013334bcd0  EFLAGS: 00010296
[  272.702427] RAX: 0000000000000149 RBX: ffffea0001978000 RCX: 0000000000000002
[  272.703498] RDX: ffff880137d10401 RSI: ffffffff81798adf RDI: 00000000ffffffff
[  272.704574] RBP: ffff88013334bcf0 R08: 0000000000000001 R09: 0000000000000000
[  272.705648] R10: ffff88013334bca0 R11: 00000000fffffffc R12: 0000000000000200
[  272.706714] R13: 00007f3577000000 R14: ffff8800b855a5a0 R15: ffff880000000000
[  272.707782] FS:  0000000000000000(0000) GS:ffff880137d00000(0000) knlGS:0000000000000000
[  272.708852] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  272.709913] CR2: 00007f142dd37000 CR3: 00000000baaf4000 CR4: 00000000000006e0
[  272.710961] Stack:
[  272.711998]  ffffea0001978000 ffff8800badbadc0 ffffea0002e77280 8000000065e000e7
[  272.713036]  ffff88013334be68 ffffffff81114671 ffff88013332a980 ffff88013334c000
[  272.714068]  ffff88013332a980 ffff8800b9dcb000 00007f3577200000 000000000101bda0
[  272.715092] Call Trace:
[  272.716100]  [<ffffffff81114671>] khugepaged+0x2227/0x2751
[  272.717105]  [<ffffffff8106f766>] ? prepare_to_wait_event+0xe4/0xe4
[  272.718094]  [<ffffffff8111244a>] ? hugepage_vma_revalidate+0x6f/0x6f
[  272.719087]  [<ffffffff8111244a>] ? hugepage_vma_revalidate+0x6f/0x6f
[  272.720067]  [<ffffffff81055f22>] kthread+0xf3/0xfb
[  272.721035]  [<ffffffff814ab198>] ? _raw_spin_unlock_irq+0x27/0x45
[  272.721990]  [<ffffffff814abaff>] ret_from_fork+0x1f/0x40
[  272.722932]  [<ffffffff81055e2f>] ? kthread_create_on_node+0x1ca/0x1ca
[  272.723860] Code: 19 e4 41 81 e4 01 fe ff ff 41 81 c4 00 02 00 00 eb 06 41 bc 01 00 00 00 4d 39 2e 77 06 4d 3b 6e 08 72 0a 4c 89 f7 e8 73 11 ff ff <0f> 0b 48 8b 53 20 48 8d 42 ff 80 e2 01 48 0f 44 c3 0f ba 28 12 
[  272.724956] RIP  [<ffffffff810f67ad>] page_add_new_anon_rmap+0x68/0x136
[  272.725918]  RSP <ffff88013334bcd0>
[  272.726890] ---[ end trace eb7290ad13e0e7f0 ]---

[  272.727842] BUG: sleeping function called from invalid context at include/linux/sched.h:2960
[  272.728798] in_atomic(): 1, irqs_disabled(): 0, pid: 38, name: khugepaged
[  272.729821] INFO: lockdep is turned off.
[  272.730762] Preemption disabled at:[<ffffffff8111464d>] khugepaged+0x2203/0x2751

[  272.732618] CPU: 2 PID: 38 Comm: khugepaged Tainted: G      D         4.7.0-rc3-next-20160615-dbg-00005-gfd11984-dirty #493
[  272.734460]  0000000000000000 ffff88013334b9d0 ffffffff811ec73b 0000000000000000
[  272.735382]  ffff88013332a980 ffff88013334b9f8 ffffffff81059b98 ffffffff8174c31c
[  272.736296]  0000000000000b90 0000000000000000 ffff88013334ba20 ffffffff81059c0f
[  272.737203] Call Trace:
[  272.738085]  [<ffffffff811ec73b>] dump_stack+0x68/0x92
[  272.738961]  [<ffffffff81059b98>] ___might_sleep+0x1fb/0x202
[  272.739831]  [<ffffffff81059c0f>] __might_sleep+0x70/0x77
[  272.740684]  [<ffffffff81048ac7>] exit_signals+0x1e/0x119
[  272.741528]  [<ffffffff8107dd86>] ? kmsg_dump+0x12c/0x154
[  272.742362]  [<ffffffff8103f23a>] do_exit+0x111/0x8f3
[  272.743184]  [<ffffffff8107dda3>] ? kmsg_dump+0x149/0x154
[  272.743996]  [<ffffffff81014b39>] oops_end+0x9d/0xa4
[  272.744801]  [<ffffffff81014c6e>] die+0x55/0x5e
[  272.745602]  [<ffffffff81012450>] do_trap+0x67/0x11d
[  272.746401]  [<ffffffff8101272d>] do_error_trap+0x100/0x10f
[  272.747190]  [<ffffffff810f67ad>] ? page_add_new_anon_rmap+0x68/0x136
[  272.747974]  [<ffffffff8107d3b9>] ? vprintk_emit+0x427/0x449
[  272.748756]  [<ffffffff81001036>] ? trace_hardirqs_off_thunk+0x1a/0x1c
[  272.749537]  [<ffffffff81012889>] do_invalid_op+0x1b/0x1d
[  272.750316]  [<ffffffff814acb65>] invalid_op+0x15/0x20
[  272.751097]  [<ffffffff810f67ad>] ? page_add_new_anon_rmap+0x68/0x136
[  272.751879]  [<ffffffff81114671>] khugepaged+0x2227/0x2751
[  272.752660]  [<ffffffff8106f766>] ? prepare_to_wait_event+0xe4/0xe4
[  272.753442]  [<ffffffff8111244a>] ? hugepage_vma_revalidate+0x6f/0x6f
[  272.754223]  [<ffffffff8111244a>] ? hugepage_vma_revalidate+0x6f/0x6f
[  272.755001]  [<ffffffff81055f22>] kthread+0xf3/0xfb
[  272.755781]  [<ffffffff814ab198>] ? _raw_spin_unlock_irq+0x27/0x45
[  272.756557]  [<ffffffff814abaff>] ret_from_fork+0x1f/0x40
[  272.757335]  [<ffffffff81055e2f>] ? kthread_create_on_node+0x1ca/0x1ca
[  272.758124] note: khugepaged[38] exited with preempt_count 1

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
