Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 006E7C43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 08:05:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 870C7222D7
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 08:05:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 870C7222D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDDA98E0002; Sat, 16 Feb 2019 03:05:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D63A58E0001; Sat, 16 Feb 2019 03:05:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C54218E0002; Sat, 16 Feb 2019 03:05:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A42D8E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 03:05:04 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id z3so20058847itj.2
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 00:05:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=ATDW+1im1+6McfmFYNDyHPkRS2FcJXcAGn4j03Aw5xA=;
        b=tVlo93e3wToCr0qA/2frm8Rf/+kk/weOm4QHEoHhWNVGs9O5bXk6v2QxnowrIYIUsV
         PZVbWizC2YJB9U1tFBto3BeHgqjv7Xg03XyWlcvfZ3u6Lf9xkWISag7YDBBDiOQe5oBW
         E6yFB2Zs988Pnywn6lYFYJvK0hmLbcOeBKJlyH3Bz4S1/gQhCXI99tpHqA9R5CVluCEp
         ihv5dIgEaqXIsKwvyJW4M2YsvF6ej3wgJCT8Zct0Qe295q9qynuWaIrn79SSGtxisRhe
         w941heHqeIXlM15Xqo7YMuBxScEZlGsZynztvtDG4v/mf/GsIL1nAQI9P6ZVHKxvF6Kk
         8hvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3lsrnxakbad8tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3LsRnXAkbAD8tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AHQUAuZ+5+BCHfrQB+Bdjl2CWitG5SoHiwGKAibUQlBkY9SQMXvUhHqG
	+m7PWfvgNpR8fk7TUgmh7tJ9q8jOcRP040maGeLf82R4YQi/6t5VefoT29USbtp8zjpaoYeKMtJ
	gGbsLfeGsB8tHBJgLINJOl9VSi60HOrjvfPze4jExxPg6lOBRl3lGlFnYvbK/VrR3sXGzSo/J2y
	4aLFBagSUdqRQPjtCZbUUKpwY7Z9VD5KIdkOW2nCCTbNVkNmqqYfG8bMR5rN7zUPToN/20spyEa
	vP6p5tla3fmutPz8lBNdfbdCYg8E7tA9n2n3lld48f4dQt7NDTGQjlPvtiyxZ3sNbYhg9nUKqIo
	HsEpaYf9csB31gGLkAq74/dtO2bW01r002GbNqZngacCnCqfY4oRM6x6Cxa64K1jYU1LbFZ9zw=
	=
X-Received: by 2002:a5d:8198:: with SMTP id u24mr7890021ion.177.1550304304319;
        Sat, 16 Feb 2019 00:05:04 -0800 (PST)
X-Received: by 2002:a5d:8198:: with SMTP id u24mr7889990ion.177.1550304303274;
        Sat, 16 Feb 2019 00:05:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550304303; cv=none;
        d=google.com; s=arc-20160816;
        b=WIggDAq4FDgv/c/l6wmRRc4pWqpQUYCBAAt10IiZm0YQV0Pu6/mpOpcaZtVMtjzBb4
         b02pIjHgKRY3ajeBBxjBHEcClZiqlcd+MUp/3rFznwqIsXebL9Fjg2jr9IPzKKDmhycp
         +4hQTbgeUKSXeNGWnAhAKuBZR/RYILh4LP7cy96J3AR0ggBntH/Az8JCB6184V4Dn9Z9
         GoFif6mHGgzpHiAJsqc7NpVLAYvb6YARfDG3OjWJw+D+dfcOMTE8xk2xwl2ZvFv7WOKU
         xmOueuWlhdQ7CGiUR1BqjlKyoKo19938fq8fO770x2RuDpYdNsH6+daLVSpJZpg3Z98g
         /qOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=ATDW+1im1+6McfmFYNDyHPkRS2FcJXcAGn4j03Aw5xA=;
        b=AXbdQYRGXLkwzVzBink6ZFr9zBQli+rONFSuAa95vessYsrAl79HnwdUIdaH86caOW
         z+wp9FlpwdDKCrMY/eSyKvM82sExiPNqX3G77dSVQgDJpRTyalKe2uBRjNLSyBWdlIa9
         qZTFdETZCoUGJdCxQRs8B5Ecoaj5CxrLzEHUtj6yP6IDtSSMkg3WaiwHkCoyooSYFLp5
         yVReo3Fp6t7cX1GWp67qiV1jz41+/CTaeq+6YOpJnHWJ+zKx83J7FTTSlPIhHiky2VZt
         15YBPKfJj3lnlZ8Y8//oOkaDrJLMVCIJwj7HjntxHjCcAVyUpNj5OJi/5TY8zaI3aDnz
         bHTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3lsrnxakbad8tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3LsRnXAkbAD8tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 5sor12726391itx.25.2019.02.16.00.05.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Feb 2019 00:05:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 3lsrnxakbad8tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3lsrnxakbad8tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3LsRnXAkbAD8tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: AHgI3Ia92SHGf1uRvzKXxRULFuC5aOsfpJchL24HY98Qr8l6q1wKFAYqRekHkUXGhVmVXmxNRi9DW5FONKDfO/+LGphUSnyq5TUN
MIME-Version: 1.0
X-Received: by 2002:a24:6c93:: with SMTP id w141mr7459266itb.35.1550304302976;
 Sat, 16 Feb 2019 00:05:02 -0800 (PST)
Date: Sat, 16 Feb 2019 00:05:02 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000045d4f10581fe59a7@google.com>
Subject: KASAN: use-after-free Read in shmem_fault
From: syzbot <syzbot+56fbe62f8c55f860fd99@syzkaller.appspotmail.com>
To: hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    aa0c38cf39de Merge branch 'fixes' of git://git.kernel.org/..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=146cadff400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=ee434566c893c7b1
dashboard link: https://syzkaller.appspot.com/bug?extid=56fbe62f8c55f860fd99
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+56fbe62f8c55f860fd99@syzkaller.appspotmail.com

==================================================================
BUG: KASAN: use-after-free in __lock_acquire+0x30e0/0x4700  
kernel/locking/lockdep.c:3215
Read of size 8 at addr ffff888098eda1a0 by task syz-executor.2/16643

CPU: 0 PID: 16643 Comm: syz-executor.2 Not tainted 5.0.0-rc6+ #68
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x172/0x1f0 lib/dump_stack.c:113
  print_address_description.cold+0x7c/0x20d mm/kasan/report.c:187
  kasan_report.cold+0x1b/0x40 mm/kasan/report.c:317
  __asan_report_load8_noabort+0x14/0x20 mm/kasan/generic_report.c:135
  __lock_acquire+0x30e0/0x4700 kernel/locking/lockdep.c:3215
  lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:3841
  __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
  _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:144
  spin_lock include/linux/spinlock.h:329 [inline]
  shmem_fault+0x5b4/0x760 mm/shmem.c:1972
  __do_fault+0x116/0x4e0 mm/memory.c:3019
  do_read_fault mm/memory.c:3430 [inline]
  do_fault mm/memory.c:3556 [inline]
  handle_pte_fault mm/memory.c:3787 [inline]
  __handle_mm_fault+0x2cbd/0x3f20 mm/memory.c:3911
  handle_mm_fault+0x43f/0xb30 mm/memory.c:3948
  faultin_page mm/gup.c:535 [inline]
  __get_user_pages+0x7b6/0x1a40 mm/gup.c:738
  populate_vma_page_range+0x20d/0x2a0 mm/gup.c:1247
  __mm_populate+0x204/0x380 mm/gup.c:1295
  mm_populate include/linux/mm.h:2388 [inline]
  vm_mmap_pgoff+0x213/0x230 mm/util.c:355
  ksys_mmap_pgoff+0xf7/0x630 mm/mmap.c:1609
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457e39
Code: ad b8 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 7b b8 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007fe43bdebc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 0000000000457e39
RDX: 0000000000000003 RSI: 0000000000b36000 RDI: 0000000020000000
RBP: 000000000073bf00 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000008031 R11: 0000000000000246 R12: 00007fe43bdec6d4
R13: 00000000004c3b9e R14: 00000000004d6c88 R15: 00000000ffffffff

Allocated by task 16643:
  save_stack+0x45/0xd0 mm/kasan/common.c:73
  set_track mm/kasan/common.c:85 [inline]
  __kasan_kmalloc mm/kasan/common.c:496 [inline]
  __kasan_kmalloc.constprop.0+0xcf/0xe0 mm/kasan/common.c:469
  kasan_kmalloc mm/kasan/common.c:504 [inline]
  kasan_slab_alloc+0xf/0x20 mm/kasan/common.c:411
  kmem_cache_alloc+0x12d/0x710 mm/slab.c:3543
  shmem_alloc_inode+0x1c/0x50 mm/shmem.c:3544
  alloc_inode+0x66/0x190 fs/inode.c:210
  new_inode_pseudo+0x19/0xf0 fs/inode.c:906
  new_inode+0x1f/0x40 fs/inode.c:935
  shmem_get_inode+0x84/0x780 mm/shmem.c:2148
  __shmem_file_setup.part.0+0x1e2/0x2b0 mm/shmem.c:3900
  __shmem_file_setup mm/shmem.c:3894 [inline]
  shmem_kernel_file_setup mm/shmem.c:3930 [inline]
  shmem_zero_setup+0xe2/0x474 mm/shmem.c:3974
  mmap_region+0x136c/0x1760 mm/mmap.c:1802
  do_mmap+0x8e2/0x1080 mm/mmap.c:1559
  do_mmap_pgoff include/linux/mm.h:2379 [inline]
  vm_mmap_pgoff+0x1c5/0x230 mm/util.c:350
  ksys_mmap_pgoff+0xf7/0x630 mm/mmap.c:1609
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 16:
  save_stack+0x45/0xd0 mm/kasan/common.c:73
  set_track mm/kasan/common.c:85 [inline]
  __kasan_slab_free+0x102/0x150 mm/kasan/common.c:458
  kasan_slab_free+0xe/0x10 mm/kasan/common.c:466
  __cache_free mm/slab.c:3487 [inline]
  kmem_cache_free+0x86/0x260 mm/slab.c:3749
  shmem_destroy_callback+0x6e/0xc0 mm/shmem.c:3555
  __rcu_reclaim kernel/rcu/rcu.h:240 [inline]
  rcu_do_batch kernel/rcu/tree.c:2452 [inline]
  invoke_rcu_callbacks kernel/rcu/tree.c:2773 [inline]
  rcu_process_callbacks+0x928/0x1390 kernel/rcu/tree.c:2754
  __do_softirq+0x266/0x95a kernel/softirq.c:292

The buggy address belongs to the object at ffff888098eda000
  which belongs to the cache shmem_inode_cache(49:syz2) of size 1184
The buggy address is located 416 bytes inside of
  1184-byte region [ffff888098eda000, ffff888098eda4a0)
The buggy address belongs to the page:
page:ffffea000263b680 count:1 mapcount:0 mapping:ffff888085ba8d80  
index:0xffff888098edaffd
flags: 0x1fffc0000000200(slab)
raw: 01fffc0000000200 ffffea000283a708 ffffea00029ce6c8 ffff888085ba8d80
raw: ffff888098edaffd ffff888098eda000 0000000100000001 ffff88805755e540
page dumped because: kasan: bad access detected
page->mem_cgroup:ffff88805755e540

Memory state around the buggy address:
  ffff888098eda080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff888098eda100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ffff888098eda180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                ^
  ffff888098eda200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff888098eda280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.

