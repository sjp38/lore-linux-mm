Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF396B0003
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 06:18:27 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id q127-v6so7116254iod.17
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 03:18:27 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d13-v6sor4697535iob.48.2018.11.11.03.18.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Nov 2018 03:18:26 -0800 (PST)
MIME-Version: 1.0
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Sun, 11 Nov 2018 16:18:14 +0500
Message-ID: <CABXGCsP_s8gwNsufESD_X8cdhECcMymMGVjbKdcDLgDX8-LGuQ@mail.gmail.com>
Subject: [4.20 rc1] WARNING: CPU: 0 PID: 1 at lib/debugobjects.c:369 __debug_object_init.cold.11+0x18/0x10a
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Since 4.20 kernels I has this warning every boot time.

[    1.495601] ODEBUG: object 0000000057e62f35 is NOT on stack
00000000bf9c4413, but annotated.
[    1.495601] WARNING: CPU: 0 PID: 1 at lib/debugobjects.c:369
__debug_object_init.cold.11+0x18/0x10a
[    1.495601] Modules linked in:
[    1.495601] CPU: 0 PID: 1 Comm: swapper/0 Not tainted
4.20.0-0.rc1.git4.1.fc30.x86_64 #1
[    1.495601] Hardware name: System manufacturer System Product
Name/ROG STRIX X470-I GAMING, BIOS 0901 07/23/2018
[    1.495601] RIP: 0010:__debug_object_init.cold.11+0x18/0x10a
[    1.495601] Code: 8b 35 ba d3 3d 01 48 c7 c7 e0 57 91 a6 e9 fa cb
fe ff 83 c0 01 48 89 de 48 c7 c7 08 fe 34 a6 89 05 e3 71 b0 02 e8 c0
67 c0 ff <0f> 0b e9 b9 f4 ff ff 83 c0 01 48 89 de 48 c7 c7 d0 fd 34 a6
89 05
[    1.495601] RSP: 0018:ffffa02ac0053cb0 EFLAGS: 00010046
[    1.495601] RAX: 0000000000000050 RBX: ffffffffa81f4e10 RCX: 0000000000000000
[    1.495601] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffffa513d460
[    1.495601] RBP: ffffffffa665eb20 R08: 0000000000000001 R09: 00000000001e1f40
[    1.495601] R10: 00000020e26fb280 R11: ffffffffa7be8a68 R12: ffffffffa80ad948
[    1.495601] R13: 000000000006dc40 R14: ffffffffa80ad940 R15: ffff9160f51d1488
[    1.495601] FS:  0000000000000000(0000) GS:ffff9160f9000000(0000)
knlGS:0000000000000000
[    1.495601] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    1.495601] CR2: ffff915c9f401000 CR3: 000000039d612000 CR4: 00000000003406f0
[    1.495601] Call Trace:
[    1.495601]  virt_efi_get_next_variable+0xa2/0x160
[    1.495601]  efivar_init+0xb6/0x365
[    1.495601]  ? efivar_ssdt_setup+0x3f/0x3f
[    1.495601]  ? lockdep_hardirqs_on+0xed/0x180
[    1.495601]  ? do_early_param+0x8e/0x8e
[    1.495601]  ? efivar_ssdt_iter+0xdb/0xdb
[    1.495601]  efisubsys_init+0x15a/0x313
[    1.495601]  ? efivar_ssdt_iter+0xdb/0xdb
[    1.495601]  ? do_early_param+0x8e/0x8e
[    1.495601]  do_one_initcall+0x5d/0x2be
[    1.495601]  ? do_early_param+0x8e/0x8e
[    1.495601]  ? rcu_read_lock_sched_held+0x79/0x80
[    1.495601]  ? do_early_param+0x8e/0x8e
[    1.495601]  kernel_init_freeable+0x21a/0x2c8
[    1.495601]  ? rest_init+0x257/0x257
[    1.495601]  kernel_init+0xa/0x109
[    1.495601]  ret_from_fork+0x27/0x50
[    1.495601] irq event stamp: 711024
[    1.495601] hardirqs last  enabled at (711023):
[<ffffffffa5a7260b>] _raw_spin_unlock_irqrestore+0x4b/0x60
[    1.495601] hardirqs last disabled at (711024):
[<ffffffffa5a723a2>] _raw_spin_lock_irqsave+0x22/0x90
[    1.495601] softirqs last  enabled at (709710):
[<ffffffffa590e3fc>] netlink_insert+0x6c/0x5f0
[    1.495601] softirqs last disabled at (709708):
[<ffffffffa5892ad9>] release_sock+0x19/0xb0
[    1.495601] ---[ end trace eaee508abfebccda ]---



--
Best Regards,
Mike Gavrilov.
