Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6931B6B0005
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 04:14:29 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id a5-v6so1126253plp.0
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 01:14:29 -0700 (PDT)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id 3-v6si1561251plr.440.2018.03.14.01.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 01:14:28 -0700 (PDT)
From: chenjiankang <chenjiankang1@huawei.com>
Subject: BUG: unable to handle kernel paing request at fffffc0000000000
Message-ID: <270af3b0-ab0f-9ee5-d5d6-3e86983b8d9b@huawei.com>
Date: Wed, 14 Mar 2018 16:14:01 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="gbk"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yisheng Xie <xieyisheng1@huawei.com>, wangkefeng.wang@huawei.com



hello everyone:
	my kernel version is 3.10.0-327.62.59.101.x86_64, and 
why this Kasan's shadow memory is lost?
	
Thanks;

BUG: unable to handle kernel paging request at fffffc0000000000
IP: [<ffffffff8142160b>] kasan_mem_to_shadow include/linux/kasan.h:20 [inline]
IP: [<ffffffff8142160b>] memory_is_poisoned_4 mm/kasan/kasan.c:122 [inline]
IP: [<ffffffff8142160b>] memory_is_poisoned mm/kasan/kasan.c:244 [inline]
IP: [<ffffffff8142160b>] check_memory_region_inline mm/kasan/kasan.c:270 [inline]
IP: [<ffffffff8142160b>] __asan_load4+0x2b/0x80 mm/kasan/kasan.c:524
PGD 0
Oops: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 1 PID: 21826 Comm: syz-executor0 Tainted: G    B          ---- ------- T 3.10.0-327.62.59.101.x86_64+ #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
task: ffff8802337ae680 ti: ffff880212dc8000 task.ti: ffff880212dc8000
RIP: 0010:[<ffffffff8142160b>]  [<ffffffff8142160b>] kasan_mem_to_shadow include/linux/kasan.h:20 [inline]
RIP: 0010:[<ffffffff8142160b>]  [<ffffffff8142160b>] memory_is_poisoned_4 mm/kasan/kasan.c:122 [inline]
RIP: 0010:[<ffffffff8142160b>]  [<ffffffff8142160b>] memory_is_poisoned mm/kasan/kasan.c:244 [inline]
RIP: 0010:[<ffffffff8142160b>]  [<ffffffff8142160b>] check_memory_region_inline mm/kasan/kasan.c:270 [inline]
RIP: 0010:[<ffffffff8142160b>]  [<ffffffff8142160b>] __asan_load4+0x2b/0x80 mm/kasan/kasan.c:524
RSP: 0018:ffff880212dcfba0  EFLAGS: 00010286
RAX: fffffbffffffffff RBX: ffff8802286ddd60 RCX: ffffffff8167b601
RDX: dffffc0000000000 RSI: 0000000000000008 RDI: fffffffffffffff8
RBP: ffff880212dcfba0 R08: 0000000000000007 R09: 0000000000000000
R10: ffff880000000000 R11: 0000000000000000 R12: ffff8802286da980
R13: 0000000000000000 R14: fffffffffffffff8 R15: ffffffff81c9b370
FS:  0000000000000000(0000) GS:ffff8800bb100000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: fffffc0000000000 CR3: 000000000255a000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Call Trace:
 [<ffffffff8167b601>] crypto_ahash_digestsize include/crypto/hash.h:148 [inline]
 [<ffffffff8167b601>] hash_sock_destruct+0x81/0x160 crypto/algif_hash.c:270
 [<ffffffff81ca20f4>] __sk_free+0x44/0x330 net/core/sock.c:1392
 [<ffffffff81ca240d>] sk_free+0x2d/0x40 net/core/sock.c:1422
 [<ffffffff816792f5>] sock_put include/net/sock.h:1722 [inline]
 [<ffffffff816792f5>] af_alg_release+0x55/0x70 crypto/af_alg.c:123
 [<ffffffff81c9b23c>] sock_release+0x5c/0x190 net/socket.c:570
 [<ffffffff81c9b38b>] sock_close+0x1b/0x20 net/socket.c:1161
 [<ffffffff8146263b>] __fput+0x1bb/0x560 fs/file_table.c:246
 [<ffffffff81462caa>] ____fput+0x1a/0x20 fs/file_table.c:283
 [<ffffffff811721df>] task_work_run+0x11f/0x1e0 kernel/task_work.c:87
 [<ffffffff8112101b>] exit_task_work include/linux/task_work.h:21 [inline]
 [<ffffffff8112101b>] do_exit+0x68b/0x1b40 kernel/exit.c:815
 [<ffffffff811225d1>] do_group_exit+0x91/0x1f0 kernel/exit.c:948
 [<ffffffff81122752>] SYSC_exit_group kernel/exit.c:959 [inline]
 [<ffffffff81122752>] SyS_exit_group+0x22/0x30 kernel/exit.c:957
 [<ffffffff81fac0bd>] system_call_fastpath+0x16/0x1b
Code: 55 48 b8 ff ff ff ff ff 7f ff ff 48 39 c7 48 89 e5 48 8b 4d 08 76 43 48 89 f8 48 ba 00 00 00 00 00 fc ff df 48 c1 e8 03 48 01 d0 <66> 83 38 00 75 07 5d c3 0f 1f 44 00 00 48 8d 77 03 49 89 f0 49
RIP  [<ffffffff8142160b>] kasan_mem_to_shadow include/linux/kasan.h:20 [inline]
RIP  [<ffffffff8142160b>] memory_is_poisoned_4 mm/kasan/kasan.c:122 [inline]
RIP  [<ffffffff8142160b>] memory_is_poisoned mm/kasan/kasan.c:244 [inline]
RIP  [<ffffffff8142160b>] check_memory_region_inline mm/kasan/kasan.c:270 [inline]
RIP  [<ffffffff8142160b>] __asan_load4+0x2b/0x80 mm/kasan/kasan.c:524
 RSP <ffff880212dcfba0>
CR2: fffffc0000000000
