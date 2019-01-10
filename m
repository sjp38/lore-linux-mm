Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0D7B8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 17:58:38 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id f18so3831647wrt.1
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:58:38 -0800 (PST)
Received: from mail-40130.protonmail.ch (mail-40130.protonmail.ch. [185.70.40.130])
        by mx.google.com with ESMTPS id k13si40782788wrn.425.2019.01.10.14.58.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 14:58:36 -0800 (PST)
Date: Thu, 10 Jan 2019 22:58:30 +0000
From: Esme <esploit@protonmail.ch>
Reply-To: Esme <esploit@protonmail.ch>
Subject: Re: PROBLEM: syzkaller found / pool corruption-overwrite / page in user-area or NULL
Message-ID: <olV6qm38nrHhMMH3bq9cY3h60MaHsW5U9n6xn3_PVP1UkFNJBNbVuS-8P_FdCazGJX6GZX_Qqe2Nj8_hbLJsgto76Xo-gLQ8We-hsc_vRKk=@protonmail.ch>
In-Reply-To: <1547159604.6911.12.camel@lca.pw>
References: <t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
 <1547150339.2814.9.camel@linux.ibm.com>
 <1547153074.6911.8.camel@lca.pw>
 <4u36JfbOrbu9CXLDErzQKvorP0gc2CzyGe60rBmZsGAGIw6RacZnIfoSsAF0I0TCnVx0OvcqCZFN6ntbgicJ66cWew9cOXRgcuWxSPdL3ko=@protonmail.ch>
 <1547154231.6911.10.camel@lca.pw>
 <hFmbfypBKySVyM6ITf55xUsPWifgqJy6MZ-kFJcYna61S-u2hoClrqr87QTF4F2LhW-K42T2lcCbvsEyGAL0dJTq5CndQBiMT6JnlW4xmdc=@protonmail.ch>
 <1547159604.6911.12.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: James Bottomley <jejb@linux.ibm.com>, "dgilbert@interlog.com" <dgilbert@interlog.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

The console debug/stacks/info from just now.  The previous config, current =
kernel from github.
--
Esme

[   75.783231] kasan: CONFIG_KASAN_INLINE enabled
[   75.785870] kasan: GPF could be caused by NULL-ptr deref or user memory =
access
[   75.787695] general protection fault: 0000 [#1] SMP KASAN
[   75.789084] CPU: 0 PID: 3434 Comm: systemd-journal Not tainted 5.0.0-rc1=
+ #5
[   75.790938] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.11.1-1ubuntu1 04/01/2014
[   75.793150] RIP: 0010:rb_insert_color+0x189/0x1480
[   75.794421] Code: 09 00 00 4d 8b 65 00 41 f6 c4 01 0f 85 01 02 00 00 48 =
ba 00 00 00 00 00 fc ff df 49 8d 4c 24 08 4d 89 e0 48 89 c8 48 c1 e8 03 <80=
> 3c 10 00 0f 85 e5 08 00 00 49 8b 44 24 08 4c 32
[   75.799181] RSP: 0018:ffff88805d4876c8 EFLAGS: 00010012
[   75.800558] RAX: 0000000000000001 RBX: 1ffff1100ba90edf RCX: 00000000000=
00008
[   75.802393] RDX: dffffc0000000000 RSI: ffffffff8c694c20 RDI: ffff88805ce=
0fc78
[   75.804221] RBP: ffff88805d487ac0 R08: 0000000000000000 R09: ffff88805b4=
6f3b0
[   75.806071] R10: ffffed100ba90f46 R11: 0000000000000003 R12: 00000000000=
00000
[   75.807867] R13: ffff88805b46f3b0 R14: ffff88805d487a98 R15: ffff88805ce=
0fc78
[   75.809705] FS:  00007f26b66568c0(0000) GS:ffff88806c000000(0000) knlGS:=
0000000000000000
[   75.811665] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   75.813090] CR2: 00007f26b33b2000 CR3: 000000006b5c8000 CR4: 00000000000=
006f0
[   75.814941] Call Trace:
[   75.815607]  ? is_bpf_text_address+0xdd/0x180
[   75.816774]  ? __bpf_address_lookup+0x310/0x310
[   75.817968]  ? ___ratelimit.cold.2+0x60/0x60
[   75.819119]  ? __kernel_text_address+0xd/0x40
[   75.820282]  ? unwind_get_return_address+0x61/0xb0
[   75.821564]  ? graph_lock+0x270/0x270
[   75.822522]  ? __save_stack_trace+0x8d/0xf0
[   75.823640]  ? find_held_lock+0x36/0x1d0
[   75.824603]  ? __bpf_trace_xdp_cpumap_enqueue+0x60/0x60
[   75.825878]  ? is_bpf_text_address+0xb4/0x180
[   75.826940]  ? lock_downgrade+0x900/0x900
[   75.827892]  ? kasan_check_read+0x11/0x20
[   75.828878]  ? rcu_is_watching+0x9d/0x160
[   75.829660]  ? rcu_cleanup_dead_rnp+0x230/0x230
[   75.830625]  ? rcu_is_watching+0x9d/0x160
[   75.831443]  ? create_object+0x5e8/0xca0
[   75.832280]  ? is_bpf_text_address+0xdd/0x180
[   75.833185]  ? __bpf_address_lookup+0x310/0x310
[   75.834159]  ? kasan_check_read+0x11/0x20
[   75.834927]  ? do_raw_write_lock+0x14f/0x310
[   75.835755]  ? do_raw_read_unlock+0x80/0x80
[   75.836587]  ? __save_stack_trace+0x8d/0xf0
[   75.837485]  create_object+0x785/0xca0
[   75.838485]  ? kmemleak_seq_show+0x190/0x190
[   75.839552]  ? kasan_check_read+0x11/0x20
[   75.840536]  ? do_raw_spin_unlock+0xa7/0x340
[   75.841680]  ? kmem_cache_alloc+0x21a/0x3c0
[   75.842718]  ? kmem_cache_alloc+0x21a/0x3c0
[   75.843829]  ? lockdep_hardirqs_on+0x421/0x610
[   75.844857]  ? trace_hardirqs_on+0xce/0x310
[   75.845915]  ? cache_grow_end+0xb1/0x1b0
[   75.846938]  ? getname_flags+0xdb/0x5d0
[   75.847964]  ? __bpf_trace_preemptirq_template+0x30/0x30
[   75.849222]  ? cache_alloc_refill+0x323/0x360
[   75.850374]  kmemleak_alloc+0x2f/0x50
[   75.851300]  kmem_cache_alloc+0x1b9/0x3c0
[   75.852344]  getname_flags+0xdb/0x5d0
[   75.853328]  ? __sanitizer_cov_trace_const_cmp4+0x16/0x20
[   75.854773]  getname+0x1e/0x20
[   75.855584]  do_sys_open+0x3a1/0x7d0
[   75.856431]  ? filp_open+0x90/0x90
[   75.857110]  __x64_sys_open+0x7e/0xc0
[   75.857836]  do_syscall_64+0x1b3/0x820
[   75.858585]  ? entry_SYSCALL_64_after_hwframe+0x3e/0xbe
[   75.859671]  ? syscall_return_slowpath+0x630/0x630
[   75.860888]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[   75.861913]  ? trace_hardirqs_on_caller+0x300/0x300
[   75.862869]  ? prepare_exit_to_usermode+0x291/0x3d0
[   75.863826]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[   75.864752]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   75.865735] RIP: 0033:0x7f26b5be783d
[   75.866444] Code: bb 20 00 00 75 10 b8 02 00 00 00 0f 05 48 3d 01 f0 ff =
ff 73 31 c3 48 83 ec 08 e8 1e f6 ff ff 48 89 04 24 b8 02 00 00 00 0f 05 <48=
> 8b 3c 24 48 89 c2 e8 67 f6 ff ff 48 89 d0 48 81
[   75.870311] RSP: 002b:00007ffd20c5cbd0 EFLAGS: 00000293 ORIG_RAX: 000000=
0000000002
[   75.872049] RAX: ffffffffffffffda RBX: 00007ffd20c5cee0 RCX: 00007f26b5b=
e783d
[   75.873759] RDX: 00000000000001a0 RSI: 0000000000080042 RDI: 000056539c3=
a9e30
[   75.875477] RBP: 000000000000000d R08: 000000000000c0c1 R09: 00000000fff=
fffff
[   75.877132] R10: 0000000000000000 R11: 0000000000000293 R12: 00000000fff=
fffff
[   75.878851] R13: 000056539c39b040 R14: 00007ffd20c5cea0 R15: 000056539c3=
a9eb0
[   75.880569] Modules linked in:
[   75.881339]
[   75.881344] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   75.881348] WARNING: possible circular locking dependency detected
[   75.881351] 5.0.0-rc1+ #5 Not tainted
[   75.881355] ------------------------------------------------------
[   75.881359] systemd-journal/3434 is trying to acquire lock:
[   75.881361] 00000000b15d7606 (console_owner){-.-.}, at: console_unlock+0=
x57d/0x1160
[   75.881371]
[   75.881374] but task is already holding lock:
[   75.881377] 00000000c5ec5b7e (kmemleak_lock){-.--}, at: create_object+0x=
5e8/0xca0
[   75.881387]
[   75.881391] which lock already depends on the new lock.
[   75.881392]
[   75.881394]
[   75.881398] the existing dependency chain (in reverse order) is:
[   75.881400]
[   75.881402] -> #2 (kmemleak_lock){-.--}:
[   75.881412]        _raw_write_lock_irqsave+0x9f/0xd0
[   75.881415]        create_object+0x5e8/0xca0
[   75.881418]        kmemleak_alloc+0x2f/0x50
[   75.881421]        __kmalloc+0x1d9/0x3f0
[   75.881424]        __tty_buffer_request_room+0x2da/0x820
[   75.881428]        __tty_insert_flip_char+0x49/0x220
[   75.881431]        uart_insert_char+0x3a4/0x6d0
[   75.881434]        serial8250_read_char+0x270/0x950
[   75.881437]        serial8250_rx_chars+0x2b/0x110
[   75.881441]        serial8250_handle_irq.part.23+0x23a/0x300
[   75.881444]        serial8250_default_handle_irq+0xd1/0x170
[   75.881448]        serial8250_interrupt+0xee/0x1b0
[   75.881451]        __handle_irq_event_percpu+0x1e4/0xae0
[   75.881454]        handle_irq_event_percpu+0xae/0x1f0
[   75.881457]        handle_irq_event+0xb8/0x160
[   75.881461]        handle_edge_irq+0x20a/0x8c0
[   75.881463]        handle_irq+0x186/0x2e8
[   75.881466]        do_IRQ+0x87/0x1c0
[   75.881469]        ret_from_intr+0x0/0x1e
[   75.881472]        do_syscall_64+0xc7/0x820
[   75.881475]        entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   75.881477]
[   75.881479] -> #1 (&port_lock_key){-.-.}:
[   75.881489]        _raw_spin_lock_irqsave+0x9f/0xd0
[   75.881493]        serial8250_console_write+0x263/0xac0
[   75.881496]        univ8250_console_write+0x69/0x80
[   75.881499]        console_unlock+0xc97/0x1160
[   75.881502]        vprintk_emit+0x3a5/0x970
[   75.881505]        vprintk_default+0x31/0x40
[   75.881508]        vprintk_func+0x85/0x130
[   75.881510]        printk+0xad/0xd3
[   75.881513]        register_console+0x77d/0xbf0
[   75.881517]        univ8250_console_init+0x3f/0x4b
[   75.881519]        console_init+0x63e/0x934
[   75.881522]        start_kernel+0x5da/0x8a7
[   75.881526]        x86_64_start_reservations+0x29/0x2b
[   75.881529]        x86_64_start_kernel+0x76/0x79
[   75.881532]        secondary_startup_64+0xa4/0xb0
[   75.881534]
[   75.881535] -> #0 (console_owner){-.-.}:
[   75.881545]        lock_acquire+0x20d/0x520
[   75.881548]        console_unlock+0x5ec/0x1160
[   75.881551]        vprintk_emit+0x3a5/0x970
[   75.881554]        vprintk_default+0x31/0x40
[   75.881557]        vprintk_func+0x85/0x130
[   75.881560]        printk+0xad/0xd3
[   75.881563]        kasan_die_handler.cold.22+0x11/0x31
[   75.881566]        notifier_call_chain+0x17b/0x390
[   75.881570]        atomic_notifier_call_chain+0xa7/0x1b0
[   75.881573]        notify_die+0x1be/0x2e0
[   75.881576]        do_general_protection+0x13e/0x330
[   75.881579]        general_protection+0x1e/0x30
[   75.881582]        rb_insert_color+0x189/0x1480
[   75.881585]        create_object+0x785/0xca0
[   75.881588]        kmemleak_alloc+0x2f/0x50
[   75.881591]        kmem_cache_alloc+0x1b9/0x3c0
[   75.881594]        getname_flags+0xdb/0x5d0
[   75.881596]        getname+0x1e/0x20
[   75.881599]        do_sys_open+0x3a1/0x7d0
[   75.881602]        __x64_sys_open+0x7e/0xc0
[   75.881605]        do_syscall_64+0x1b3/0x820
[   75.881609]        entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   75.881610]
[   75.881614] other info that might help us debug this:
[   75.881615]
[   75.881618] Chain exists of:
[   75.881619]   console_owner --> &port_lock_key --> kmemleak_lock
[   75.881632]
[   75.881635]  Possible unsafe locking scenario:
[   75.881637]
[   75.881640]        CPU0                    CPU1
[   75.881643]        ----                    ----
[   75.881645]   lock(kmemleak_lock);
[   75.881651]                                lock(&port_lock_key);
[   75.881658]                                lock(kmemleak_lock);
[   75.881664]   lock(console_owner);
[   75.881670]
[   75.881672]  *** DEADLOCK ***
[   75.881674]
[   75.881677] 3 locks held by systemd-journal/3434:
[   75.881679]  #0: 00000000c5ec5b7e (kmemleak_lock){-.--}, at: create_obje=
ct+0x5e8/0xca0
[   75.881690]  #1: 00000000aca2d278 (rcu_read_lock){....}, at: atomic_noti=
fier_call_chain+0x0/0x1b0
[   75.881703]  #2: 00000000afe6836d (console_lock){+.+.}, at: vprintk_emit=
+0x385/0x970
[   75.881715]
[   75.881717] stack backtrace:
[   75.881721] CPU: 0 PID: 3434 Comm: systemd-journal Not tainted 5.0.0-rc1=
+ #5
[   75.881726] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.11.1-1ubuntu1 04/01/2014
[   75.881729] Call Trace:
[   75.881732]  dump_stack+0x1d3/0x2c2
[   75.881735]  ? dump_stack_print_info.cold.1+0x20/0x20
[   75.881739]  print_circular_bug.isra.34.cold.56+0x1bc/0x27a
[   75.881742]  ? save_trace+0xe0/0x2a0
[   75.881745]  __lock_acquire+0x3320/0x4d00
[   75.881748]  ? mark_held_locks+0x130/0x130
[   75.881750]  ? put_dec+0x48/0x100
[   75.881754]  ? __sanitizer_cov_trace_const_cmp4+0x16/0x20
[   75.881757]  ? enable_ptr_key_workfn+0x30/0x30
[   75.881760]  ? memcpy+0x50/0x60
[   75.881763]  ? __sanitizer_cov_trace_const_cmp8+0x18/0x20
[   75.881766]  ? vsnprintf+0x214/0x1a30
[   75.881769]  ? graph_lock+0x270/0x270
[   75.881773]  ? __sanitizer_cov_trace_const_cmp1+0x1a/0x20
[   75.881776]  ? kernel_poison_pages+0x133/0x220
[   75.881779]  ? find_held_lock+0x36/0x1d0
[   75.881782]  lock_acquire+0x20d/0x520
[   75.881785]  ? console_unlock+0x57d/0x1160
[   75.881788]  ? lock_release+0xaf0/0xaf0
[   75.881791]  ? do_raw_spin_unlock+0xa7/0x340
[   75.881794]  ? do_raw_spin_trylock+0x280/0x280
[   75.881797]  ? trace_hardirqs_on+0x310/0x310
[   75.881800]  console_unlock+0x5ec/0x1160
[   75.881803]  ? console_unlock+0x57d/0x1160
[   75.881806]  ? devkmsg_read+0xbd0/0xbd0
[   75.881809]  ? trace_hardirqs_on+0x310/0x310
[   75.881812]  ? vprintk_emit+0x385/0x970
[   75.881816]  ? _raw_spin_unlock_irqrestore+0x63/0xc0
[   75.881819]  ? vprintk_emit+0x385/0x970
[   75.881822]  ? __down_trylock_console_sem+0x168/0x220
[   75.881825]  ? vprintk_emit+0x385/0x970
[   75.881828]  vprintk_emit+0x3a5/0x970
[   75.881831]  ? wake_up_klogd+0x130/0x130
[   75.881834]  ? mark_held_locks+0x130/0x130
[   75.881837]  ? print_usage_bug+0xe0/0xe0
[   75.881840]  ? __lock_acquire+0x632/0x4d00
[   75.881843]  ? graph_lock+0x270/0x270
[   75.881846]  ? __lock_acquire+0x632/0x4d00
[   75.881848]  vprintk_default+0x31/0x40
[   75.881851]  vprintk_func+0x85/0x130
[   75.881854]  printk+0xad/0xd3
[   75.881857]  ? kmsg_dump_rewind_nolock+0xf0/0xf0
[   75.881860]  ? kasan_check_read+0x11/0x20
[   75.881864]  ? __sanitizer_cov_trace_const_cmp8+0x18/0x20
[   75.881867]  ? kasan_die_handler.cold.22+0x5/0x31
[   75.881870]  ? kasan_die_handler+0x1a/0x31
[   75.881873]  kasan_die_handler.cold.22+0x11/0x31
[   75.881876]  notifier_call_chain+0x17b/0x390
[   75.881880]  ? unregister_die_notifier+0x20/0x20
[   75.881883]  ? rcu_is_watching+0x9d/0x160
[   75.881886]  ? rcu_cleanup_dead_rnp+0x230/0x230
[   75.881889]  ? kasan_check_read+0x11/0x20
[   75.881892]  ? rcu_is_watching+0x9d/0x160
[   75.881895]  ? __sanitizer_cov_trace_cmp8+0x18/0x20
[   75.881899]  ? rcu_cleanup_dead_rnp+0x230/0x230
[   75.881902]  atomic_notifier_call_chain+0xa7/0x1b0
[   75.881905]  ? blocking_notifier_call_chain+0x1a0/0x1a0
[   75.881908]  notify_die+0x1be/0x2e0
[   75.881912]  ? __atomic_notifier_call_chain+0x1c0/0x1c0
[   75.881915]  ? rb_insert_color+0x189/0x1480
[   75.881918]  ? search_exception_tables+0x47/0x50
[   75.881921]  ? fixup_exception+0xb9/0xf0
[   75.881924]  do_general_protection+0x13e/0x330
[   75.881927]  general_protection+0x1e/0x30
[   75.881930] RIP: 0010:rb_insert_color+0x189/0x1480
[   75.881940] Code: 09 00 00 4d 8b 65 00 41 f6 c4 01 0f 85 01 02 00 00 48 =
ba 00 00 00 00 00 fc ff df 49 8d 4c 24 08 4d 89 e0 48 89 c8 48 c1 e8 03 <80=
> 3c 10 00 0f 85 e5 08 00 00 49 8b 44 24 08 4c 39
[   75.881943] RSP: 0018:ffff88805d4876c8 EFLAGS: 00010012
[   75.881950] RAX: 0000000000000001 RBX: 1ffff1100ba90edf RCX: 00000000000=
00008
[   75.881954] RDX: dffffc0000000000 RSI: ffffffff8c694c20 RDI: ffff88805ce=
0fc78
[   75.881959] RBP: ffff88805d487ac0 R08: 0000000000000000 R09: ffff88805b4=
6f3b0
[   75.881963] R10: ffffed100ba90f46 R11: 0000000000000003 R12: 00000000000=
00000
[   75.881968] R13: ffff88805b46f3b0 R14: ffff88805d487a98 R15: ffff88805ce=
0fc78
[   75.881971]  ? is_bpf_text_address+0xdd/0x180
[   75.881974]  ? __bpf_address_lookup+0x310/0x310
[   75.881977]  ? ___ratelimit.cold.2+0x60/0x60
[   75.881980]  ? __kernel_text_address+0xd/0x40
[   75.881984]  ? unwind_get_return_address+0x61/0xb0
[   75.881986]  ? graph_lock+0x270/0x270
[   75.881990]  ? __save_stack_trace+0x8d/0xf0
[   75.881992]  ? find_held_lock+0x36/0x1d0
[   75.881996]  ? __bpf_trace_xdp_cpumap_enqueue+0x60/0x60
[   75.881999]  ? is_bpf_text_address+0xb4/0x180
[   75.882002]  ? lock_downgrade+0x900/0x900
[   75.882005]  ? kasan_check_read+0x11/0x20
[   75.882008]  ? rcu_is_watching+0x9d/0x160
[   75.882011]  ? rcu_cleanup_dead_rnp+0x230/0x230
[   75.882014]  ? rcu_is_watching+0x9d/0x160
[   75.882017]  ? create_object+0x5e8/0xca0
[   75.882020]  ? is_bpf_text_address+0xdd/0x180
[   75.882024]  ? __bpf_address_lookup+0x310/0x310
[   75.882027]  ? kasan_check_read+0x11/0x20
[   75.882030]  ? do_raw_write_lock+0x14f/0x310
[   75.882033]  ? do_raw_read_unlock+0x80/0x80
[   75.882036]  ? __save_stack_trace+0x8d/0xf0
[   75.882039]  create_object+0x785/0xca0
[   75.882042]  ? kmemleak_seq_show+0x190/0x190
[   75.882045]  ? kasan_check_read+0x11/0x20
[   75.882048]  ? do_raw_spin_unlock+0xa7/0x340
[   75.882051]  ? kmem_cache_alloc+0x21a/0x3c0
[   75.882054]  ? kmem_cache_alloc+0x21a/0x3c0
[   75.882057]  ? lockdep_hardirqs_on+0x421/0x610
[   75.882060]  ? trace_hardirqs_on+0xce/0x310
[   75.882063]  ? cache_grow_end+0xb1/0x1b0
[   75.882066]  ? getname_flags+0xdb/0x5d0
[   75.882070]  ? __bpf_trace_preemptirq_template+0x30/0x30
[   75.882073]  ? cache_alloc_refill+0x323/0x360
[   75.882076]  kmemleak_alloc+0x2f/0x50
[   75.882079]  kmem_cache_alloc+0x1b9/0x3c0
[   75.882081]  getname_flags+0xdb/0x5d0
[   75.882085]  ? __sanitizer_cov_trace_const_cmp4+0x16/0x20
[   75.882088]  getname+0x1e/0x20
[   75.882090]  do_sys_open+0x3a1/0x7d0
[   75.882093]  ? filp_open+0x90/0x90
[   75.882096]  __x64_sys_open+0x7e/0xc0
[   75.882099]  do_syscall_64+0x1b3/0x820
[   75.882102]  ? entry_SYSCALL_64_after_hwframe+0x3e/0xbe
[   75.882106]  ? syscall_return_slowpath+0x630/0x630
[   75.882109]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[   75.882112]  ? trace_hardirqs_on_caller+0x300/0x300
[   75.882115]  ? prepare_exit_to_usermode+0x2
[   75.882120] Lost 11 message(s)!
[   76.084233] ---[ end trace 66c6a3b7a8d84213 ]---
[   76.085119] RIP: 0010:rb_insert_color+0x189/0x1480
[   76.086045] Code: 09 00 00 4d 8b 65 00 41 f6 c4 01 0f 85 01 02 00 00 48 =
ba 00 00 00 00 00 fc ff df 49 8d 4c 24 08 4d 89 e0 48 89 c8 48 c1 e8 03 <80=
> 3c 10 00 0f 85 e5 08 00 00 49 8b 44 24 08 4c 30
[   76.089566] RSP: 0018:ffff88805d4876c8 EFLAGS: 00010012
[   76.090586] RAX: 0000000000000001 RBX: 1ffff1100ba90edf RCX: 00000000000=
00008
[   76.091969] RDX: dffffc0000000000 RSI: ffffffff8c694c20 RDI: ffff88805ce=
0fc78
[   76.093319] RBP: ffff88805d487ac0 R08: 0000000000000000 R09: ffff88805b4=
6f3b0
[   76.094684] R10: ffffed100ba90f46 R11: 0000000000000003 R12: 00000000000=
00000
[   76.096052] R13: ffff88805b46f3b0 R14: ffff88805d487a98 R15: ffff88805ce=
0fc78
[   76.097440] FS:  00007f26b66568c0(0000) GS:ffff88806c000000(0000) knlGS:=
0000000000000000
[   76.098998] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   76.100122] CR2: 00007f26b33b2000 CR3: 000000006b5c8000 CR4: 00000000000=
006f0
[   76.101566] Kernel panic - not syncing: Fatal exception
[   76.104691] Kernel Offset: disabled
[   76.105407] Rebooting in 86400 seconds..




Sent with ProtonMail Secure Email.

=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original Me=
ssage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Thursday, January 10, 2019 5:33 PM, Qian Cai <cai@lca.pw> wrote:

> On Thu, 2019-01-10 at 21:35 +0000, Esme wrote:
>
> > The repro.report is from a different test system, I pulled the attached=
 config
> > from proc (attached);
>
> So, if the report is not right one. Where is the right crash stack trace =
then
> that using the exact same config.?
