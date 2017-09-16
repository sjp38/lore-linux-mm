Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C44D6B0038
	for <linux-mm@kvack.org>; Sat, 16 Sep 2017 09:23:06 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 43so5260264qtr.6
        for <linux-mm@kvack.org>; Sat, 16 Sep 2017 06:23:06 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o8sor1422212qtf.32.2017.09.16.06.23.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Sep 2017 06:23:05 -0700 (PDT)
MIME-Version: 1.0
From: =?UTF-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Date: Sat, 16 Sep 2017 18:22:48 +0500
Message-ID: <CABXGCsMWqG5yAK48Nqjr858WJbCUM_Mj+ponEjv21bWAo_4LUQ@mail.gmail.com>
Subject: WARNING: CPU: 0 PID: 0 at arch/x86/mm/tlb.c:245 initialize_tlbstate_and_flush+0x84/0x120
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: CPU: 0 PID: 0 at arch/x86/mm/tlb.c:245
initialize_tlbstate_and_flush+0x84/0x120
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted
4.14.0-0.rc0.git5.1.fc28.x86_64+debug #1
[    0.000000] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[    0.000000] task: ffffffffb2e19500 task.stack: ffffffffb2e00000
[    0.000000] RIP: 0010:initialize_tlbstate_and_flush+0x84/0x120
[    0.000000] RSP: 0000:ffffffffb2e03e60 EFLAGS: 00010046
[    0.000000] RAX: 0000000422e12000 RBX: ffffffffb2ffd560 RCX: 0000000422e12000
[    0.000000] RDX: 00000000000406b0 RSI: 00000003f0000000 RDI: 000000000000d500
[    0.000000] RBP: ffffffffb2e03e70 R08: 0000000000000001 R09: 0000000000000001
[    0.000000] R10: ffffffffb2e03e78 R11: 0000000000000001 R12: 0000000000000000
[    0.000000] R13: ffffffffb2e19500 R14: 0000000000000000 R15: ffff8f317dc0d520
[    0.000000] FS:  0000000000000000(0000) GS:ffff8f317dc00000(0000)
knlGS:0000000000000000
[    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.000000] CR2: ffff8f319f5ff000 CR3: 0000000422e12000 CR4: 00000000000406b0
[    0.000000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    0.000000] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[    0.000000] Call Trace:
[    0.000000]  cpu_init+0x1fc/0x3f0
[    0.000000]  ? set_pte_vaddr+0x41/0x70
[    0.000000]  trap_init+0x4b/0x5d
[    0.000000]  start_kernel+0x2d7/0x52f
[    0.000000]  x86_64_start_reservations+0x24/0x26
[    0.000000]  x86_64_start_kernel+0x78/0x7b
[    0.000000]  secondary_startup_64+0xa5/0xa5
[    0.000000] Code: 48 01 f1 48 39 ca 0f 85 9d 00 00 00 48 8b 15 38
60 12 01 f7 c2 00 00 02 00 74 12 65 48 8b 15 d4 26 16 4e f7 c2 00 00
02 00 75 02 <0f> ff 48 25 00 f0 ff ff 48 89 c7 ff 14 25 18 8c d9 b2 65
66 c7
[    0.000000] ---[ end trace 627be1b8e600abde ]---


Anybody can look what is culprit here?
This occurred every boot many times on my machine.


--
Best Regards,
Mike Gavrilov.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
