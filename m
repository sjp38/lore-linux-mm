Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 482376B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 10:14:12 -0400 (EDT)
Received: by ewy9 with SMTP id 9so1341211ewy.14
        for <linux-mm@kvack.org>; Thu, 04 Aug 2011 07:14:08 -0700 (PDT)
Date: Thu, 4 Aug 2011 17:13:07 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: select_task_rq_fair: WARNING: at kernel/lockdep.c match_held_lock
Message-ID: <20110804141306.GA3536@swordfish.minsk.epam.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

Hello,
Got the following trace on 3.0-git19 (07865-g1280ea8):

[  132.794685] WARNING: at kernel/lockdep.c:3117 match_held_lock+0xf6/0x12e()
[  132.794687] Hardware name: Aspire 5741G    
[  132.794689] Modules linked in: kvm_intel kvm tun ipv6 microcode snd_hda_codec_hdmi snd_hda_codec_realtek broadcom snd_hda_intel snd_hda_codec tg3 snd_pcm snd_timer snd soundcore acer_wmi evdev libphy sparse_keymap psmouse snd_page_alloc
pcspkr battery ac wmi button ehci_hcd sr_mod cdrom usbcore sd_mod ahci
[  132.794731] Pid: 4029, comm: qemu-system-x86 Not tainted 3.1.0-dbg-07865-g1280ea8-dirty #668
[  132.794733] Call Trace:
[  132.794736]  <IRQ>  [<ffffffff8103e4e0>] warn_slowpath_common+0x7e/0x96
[  132.794744]  [<ffffffff8103e50d>] warn_slowpath_null+0x15/0x17
[  132.794748]  [<ffffffff8106dcee>] match_held_lock+0xf6/0x12e
[  132.794751]  [<ffffffff8106dd88>] lock_is_held+0x62/0xa6
[  132.794757]  [<ffffffff81086471>] cgroup_lock_is_held+0x10/0x12
[  132.794762]  [<ffffffff810368a2>] set_task_cpu+0x1ac/0x3e3
[  132.794766]  [<ffffffff8103856a>] ? select_task_rq_fair+0x5c0/0x9ca
[  132.794769]  [<ffffffff8103748d>] ? try_to_wake_up+0x29/0x28b
[  132.794773]  [<ffffffff8103748d>] ? try_to_wake_up+0x29/0x28b
[  132.794779]  [<ffffffff812552a5>] ? do_raw_spin_lock+0x6b/0x122
[  132.794783]  [<ffffffff81037603>] try_to_wake_up+0x19f/0x28b
[  132.794787]  [<ffffffff810603ed>] ? update_rmtp+0x65/0x65
[  132.794790]  [<ffffffff8103770e>] wake_up_process+0x10/0x12
[  132.794794]  [<ffffffff8106040a>] hrtimer_wakeup+0x1d/0x21
[  132.794797]  [<ffffffff81060816>] __run_hrtimer+0x1b1/0x372
[  132.794800]  [<ffffffff810613a2>] hrtimer_interrupt+0xe6/0x1b0
[  132.794805]  [<ffffffff810185d5>] smp_apic_timer_interrupt+0x80/0x93
[  132.794810]  [<ffffffff81493af3>] apic_timer_interrupt+0x73/0x80
[  132.794812]  <EOI>  [<ffffffff810fb998>] ? do_mmu_notifier_register+0x66/0x125
[  132.794822]  [<ffffffff810ec132>] ? mm_take_all_locks+0x10b/0x165
[  132.794826]  [<ffffffff810ec160>] ? mm_take_all_locks+0x139/0x165
[  132.794829]  [<ffffffff810ec132>] ? mm_take_all_locks+0x10b/0x165
[  132.794832]  [<ffffffff810fb9a0>] do_mmu_notifier_register+0x6e/0x125
[  132.794836]  [<ffffffff810fba72>] mmu_notifier_register+0xe/0x10
[  132.794852]  [<ffffffffa01fcc0d>] kvm_dev_ioctl+0x297/0x400 [kvm]
[  132.794857]  [<ffffffff81119022>] do_vfs_ioctl+0x46c/0x4ad
[  132.794862]  [<ffffffff8110a68d>] ? fget_light+0xed/0x2a7
[  132.794867]  [<ffffffff81492fca>] ? sysret_check+0x2e/0x69
[  132.794871]  [<ffffffff811190b4>] sys_ioctl+0x51/0x75
[  132.794875]  [<ffffffff81492f92>] system_call_fastpath+0x16/0x1b
[  132.794877] ---[ end trace 298584c4014cd2b8 ]---


	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
