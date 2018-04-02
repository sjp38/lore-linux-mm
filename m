Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55FAE6B0027
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 04:51:58 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id o3-v6so2682327pls.11
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 01:51:58 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50102.outbound.protection.outlook.com. [40.107.5.102])
        by mx.google.com with ESMTPS id j25si9419675pgn.592.2018.04.02.01.51.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 02 Apr 2018 01:51:57 -0700 (PDT)
Subject: Re: [lkp-robot] [list_lru] 42658d54ce: BUG:unable_to_handle_kernel
References: <20180402031739.GC3101@yexl-desktop>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <235cb8c6-1f19-0573-4dc5-1da9d9063200@virtuozzo.com>
Date: Mon, 2 Apr 2018 11:51:48 +0300
MIME-Version: 1.0
In-Reply-To: <20180402031739.GC3101@yexl-desktop>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <xiaolong.ye@intel.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lkp@01.org

Hi, Xiaolong,

thanks for reporting this.

I'll make needed changes in v2.

Kirill

On 02.04.2018 06:17, kernel test robot wrote:
> 
> FYI, we noticed the following commit (built with gcc-7):
> 
> commit: 42658d54ce4d9c25c8a286651c60cbc869f2f91e ("list_lru: Add memcg argument to list_lru_from_kmem()")
> url: https://github.com/0day-ci/linux/commits/Kirill-Tkhai/Improve-shrink_slab-scalability-old-complexity-was-O-n-2-new-is-O-n/20180323-052754
> base: git://git.cmpxchg.org/linux-mmotm.git master
> 
> in testcase: boot
> 
> on test machine: qemu-system-x86_64 -enable-kvm -cpu Haswell,+smep,+smap -smp 2 -m 512M
> 
> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):
> 
> 
> +------------------------------------------+------------+------------+
> |                                          | 7f23acedf7 | 42658d54ce |
> +------------------------------------------+------------+------------+
> | boot_successes                           | 10         | 0          |
> | boot_failures                            | 0          | 19         |
> | BUG:unable_to_handle_kernel              | 0          | 19         |
> | Oops:#[##]                               | 0          | 19         |
> | RIP:list_lru_add                         | 0          | 19         |
> | Kernel_panic-not_syncing:Fatal_exception | 0          | 19         |
> +------------------------------------------+------------+------------+
> 
> 
> 
> [  465.702558] BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
> [  465.721123] PGD 800000001740e067 P4D 800000001740e067 PUD 1740f067 PMD 0 
> [  465.737033] Oops: 0002 [#1] PTI
> [  465.744456] CPU: 0 PID: 163 Comm: rc.local Not tainted 4.16.0-rc5-mm1-00298-g42658d5 #1
> [  465.760374] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [  465.773920] RIP: 0010:list_lru_add+0x1e/0x70
> [  465.780850] RSP: 0018:ffffc90001f0fe18 EFLAGS: 00010246
> [  465.791551] RAX: ffff88001a1f16f0 RBX: ffff88000001a508 RCX: 0000000000000001
> [  465.806362] RDX: 0000000000000000 RSI: ffff88000001a520 RDI: 0000000000000246
> [  465.821265] RBP: ffffc90001f0fe28 R08: 0000000000000000 R09: 0000000000000001
> [  465.836206] R10: ffffc90001f0fd88 R11: 0000000000000001 R12: ffff88001a1f16f0
> [  465.850706] R13: ffffffff82c213d8 R14: ffffffff811aa4d5 R15: ffff88001a1f15f0
> [  465.865285] FS:  00007fccddf45700(0000) GS:ffffffff82e3f000(0000) knlGS:0000000000000000
> [  465.881839] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  465.893412] CR2: 0000000000000000 CR3: 0000000017868004 CR4: 00000000000206f0
> [  465.907019] Call Trace:
> [  465.911369]  d_lru_add+0x37/0x40
> [  465.917037]  dput+0x181/0x1d0
> [  465.922225]  __fput+0x1a7/0x1c0
> [  465.928052]  ____fput+0x9/0x10
> [  465.933601]  task_work_run+0x84/0xc0
> [  465.940404]  exit_to_usermode_loop+0x4e/0x80
> [  465.948013]  do_syscall_64+0x179/0x190
> [  465.954817]  entry_SYSCALL_64_after_hwframe+0x42/0xb7
> [  465.963476] RIP: 0033:0x7fccdd625040
> [  465.969435] RSP: 002b:00007fff689ff258 EFLAGS: 00000246 ORIG_RAX: 0000000000000003
> [  465.981362] RAX: 0000000000000000 RBX: 00000000006f1c08 RCX: 00007fccdd625040
> [  465.993162] RDX: 00000000fbada408 RSI: 0000000000000001 RDI: 0000000000000003
> [  466.005567] RBP: 0000000000000000 R08: 0000000000000078 R09: 0000000001000000
> [  466.018316] R10: 0000000000000008 R11: 0000000000000246 R12: 0000000000000000
> [  466.030899] R13: 000000000046e150 R14: 00000000000004f0 R15: 0000000000000001
> [  466.043602] Code: c3 66 90 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 41 54 53 48 8b 1f 49 89 f4 48 89 df e8 db f6 f5 00 49 8b 04 24 49 39 c4 75 3d <48> c7 04 25 00 00 00 00 00 00 00 00 48 8b 43 50 48 8d 53 48 4c 
> [  466.077316] RIP: list_lru_add+0x1e/0x70 RSP: ffffc90001f0fe18
> [  466.087943] CR2: 0000000000000000
> [  466.094137] ---[ end trace aeec590ab6dccbb2 ]---
> 
> 
> To reproduce:
> 
>         git clone https://github.com/intel/lkp-tests.git
>         cd lkp-tests
>         bin/lkp qemu -k <bzImage> job-script  # job-script is attached in this email
> 
> 
> 
> Thanks,
> Xiaolong
> 
