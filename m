Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C422CC41514
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 19:40:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D8BD22CE9
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 19:40:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D8BD22CE9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDF246B0006; Fri, 30 Aug 2019 15:40:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D68ED6B0008; Fri, 30 Aug 2019 15:40:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2FA16B000A; Fri, 30 Aug 2019 15:40:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0183.hostedemail.com [216.40.44.183])
	by kanga.kvack.org (Postfix) with ESMTP id 996E36B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 15:40:08 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 3DEAA181AC9AE
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 19:40:08 +0000 (UTC)
X-FDA: 75880110096.19.match63_1218e7ba6c11
X-HE-Tag: match63_1218e7ba6c11
X-Filterd-Recvd-Size: 9122
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 19:40:07 +0000 (UTC)
Received: by mail-io1-f70.google.com with SMTP id i2so4073108iof.22
        for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:40:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:date:message-id:subject:from:to;
        bh=M1uUnMMBM1WH5LABsz/rPOg4DwKyZQOtVK+xT/oVcYY=;
        b=IKvJovY7LtKSj2pqbb+fzAKDcJhWqoT16xAah7ZlYJiEw3TE4NcWJpoqwxheaxJFa7
         mIY4EQxL3aqpgsDqf0Ljkd/oJZ68QL+560fEB0zmjwF9K0Hg3Tlb0xBqtnuoTBdkuNzr
         mMnprb+c88z3C4M6gQKp7+0KLIhGqR8b4uV3BpRE+rkotQsf82TA5LC5DvFW8KOsQvTy
         RhUL5UJycL5oBwJBSpMKjOVmxDKm1sYna/x2W+PlspDKDAAPNmSpvcg5NJXr+vWU5rVG
         Dwn7YhgXQUr6pZ6nVqwJmhbgEcnPrtQdGoXy75PtiMX/AlmGS57EW7drbefz6wDThi9j
         dhGg==
X-Gm-Message-State: APjAAAUUxEddk7K0GdhSdfpl7qv2QIVO78cyyt+oJXrk1MZw2rRmps6x
	GjoJNPP0hh8llZnkmbB4IwFC4sVTpVJE7ZkYm4QXue4SaOOG
X-Google-Smtp-Source: APXvYqw/ID6uOSg4orFPj7Nh4pNkBiSZ8HwaJKWtfOde3z295JQRvJt/SKlILFqnSmIq9n5Kv7YzliHlUAzxfrQ0ToVLhIMaBNl/
MIME-Version: 1.0
X-Received: by 2002:a02:6a68:: with SMTP id m40mr17422810jaf.135.1567194006930;
 Fri, 30 Aug 2019 12:40:06 -0700 (PDT)
Date: Fri, 30 Aug 2019 12:40:06 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000013d6e305915aca08@google.com>
Subject: KASAN: use-after-free Read in shmem_fault (2)
From: syzbot <syzbot+03ee87124ee05af991bd@syzkaller.appspotmail.com>
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

HEAD commit:    a55aa89a Linux 5.3-rc6
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=12f4beb6600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=2a6a2b9826fdadf9
dashboard link: https://syzkaller.appspot.com/bug?extid=03ee87124ee05af991bd
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+03ee87124ee05af991bd@syzkaller.appspotmail.com

==================================================================
BUG: KASAN: use-after-free in perf_trace_lock_acquire+0x401/0x530  
include/trace/events/lock.h:13
Read of size 8 at addr ffff8880a5cf2c50 by task syz-executor.0/26173

CPU: 0 PID: 26173 Comm: syz-executor.0 Not tainted 5.3.0-rc6 #146
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x172/0x1f0 lib/dump_stack.c:113
  print_address_description.cold+0xd4/0x306 mm/kasan/report.c:351
  __kasan_report.cold+0x1b/0x36 mm/kasan/report.c:482
  kasan_report+0x12/0x17 mm/kasan/common.c:618
  __asan_report_load8_noabort+0x14/0x20 mm/kasan/generic_report.c:132
  perf_trace_lock_acquire+0x401/0x530 include/trace/events/lock.h:13
  trace_lock_acquire include/trace/events/lock.h:13 [inline]
  lock_acquire+0x2de/0x410 kernel/locking/lockdep.c:4411
  __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
  _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:151
  spin_lock include/linux/spinlock.h:338 [inline]
  shmem_fault+0x5ec/0x7b0 mm/shmem.c:2034
  __do_fault+0x111/0x540 mm/memory.c:3083
  do_shared_fault mm/memory.c:3535 [inline]
  do_fault mm/memory.c:3613 [inline]
  handle_pte_fault mm/memory.c:3840 [inline]
  __handle_mm_fault+0x2adf/0x3f20 mm/memory.c:3964
  handle_mm_fault+0x1b5/0x6b0 mm/memory.c:4001
  do_user_addr_fault arch/x86/mm/fault.c:1441 [inline]
  __do_page_fault+0x536/0xdd0 arch/x86/mm/fault.c:1506
  do_page_fault+0x38/0x590 arch/x86/mm/fault.c:1530
  page_fault+0x39/0x40 arch/x86/entry/entry_64.S:1202
RIP: 0010:copy_user_generic_unrolled+0x89/0xc0  
arch/x86/lib/copy_user_64.S:91
Code: 38 4c 89 47 20 4c 89 4f 28 4c 89 57 30 4c 89 5f 38 48 8d 76 40 48 8d  
7f 40 ff c9 75 b6 89 d1 83 e2 07 c1 e9 03 74 12 4c 8b 06 <4c> 89 07 48 8d  
76 08 48 8d 7f 08 ff c9 75 ee 21 d2 74 10 89 d1 8a
RSP: 0018:ffff88806b927e18 EFLAGS: 00010202
RAX: 0000000000000001 RBX: 0000000000000008 RCX: 0000000000000001
RDX: 0000000000000000 RSI: ffff88806b927e80 RDI: 0000000020000000
RBP: ffff88806b927e50 R08: 0000000500000004 R09: ffffed100d724fd1
R10: ffffed100d724fd0 R11: ffff88806b927e87 R12: 0000000020000000
R13: ffff88806b927e80 R14: 0000000020000008 R15: 00007ffffffff000
  copy_to_user include/linux/uaccess.h:152 [inline]
  do_pipe2+0xec/0x160 fs/pipe.c:857
  __do_sys_pipe fs/pipe.c:878 [inline]
  __se_sys_pipe fs/pipe.c:876 [inline]
  __x64_sys_pipe+0x33/0x40 fs/pipe.c:876
  do_syscall_64+0xfd/0x6a0 arch/x86/entry/common.c:296
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x459879
Code: fd b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 cb b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f833e81fc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000016
RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 0000000000459879
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000020000000
RBP: 000000000075c118 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007f833e8206d4
R13: 00000000004f5b47 R14: 00000000004db7b8 R15: 00000000ffffffff

Allocated by task 25774:
  save_stack+0x23/0x90 mm/kasan/common.c:69
  set_track mm/kasan/common.c:77 [inline]
  __kasan_kmalloc mm/kasan/common.c:493 [inline]
  __kasan_kmalloc.constprop.0+0xcf/0xe0 mm/kasan/common.c:466
  kasan_slab_alloc+0xf/0x20 mm/kasan/common.c:501
  slab_post_alloc_hook mm/slab.h:520 [inline]
  slab_alloc mm/slab.c:3319 [inline]
  kmem_cache_alloc+0x121/0x710 mm/slab.c:3483
  shmem_alloc_inode+0x1c/0x50 mm/shmem.c:3630
  alloc_inode+0x68/0x1e0 fs/inode.c:227
  new_inode_pseudo+0x19/0xf0 fs/inode.c:916
  new_inode+0x1f/0x40 fs/inode.c:945
  shmem_get_inode+0x84/0x7e0 mm/shmem.c:2228
  __shmem_file_setup.part.0+0x1e2/0x2b0 mm/shmem.c:3985
  __shmem_file_setup mm/shmem.c:3979 [inline]
  shmem_kernel_file_setup mm/shmem.c:4015 [inline]
  shmem_zero_setup+0xe1/0x4cc mm/shmem.c:4059
  mmap_region+0x13d5/0x1760 mm/mmap.c:1804
  do_mmap+0x82e/0x1090 mm/mmap.c:1561
  do_mmap_pgoff include/linux/mm.h:2374 [inline]
  vm_mmap_pgoff+0x1c5/0x230 mm/util.c:391
  ksys_mmap_pgoff+0xf7/0x630 mm/mmap.c:1611
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0xfd/0x6a0 arch/x86/entry/common.c:296
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 26359:
  save_stack+0x23/0x90 mm/kasan/common.c:69
  set_track mm/kasan/common.c:77 [inline]
  __kasan_slab_free+0x102/0x150 mm/kasan/common.c:455
  kasan_slab_free+0xe/0x10 mm/kasan/common.c:463
  __cache_free mm/slab.c:3425 [inline]
  kmem_cache_free+0x86/0x320 mm/slab.c:3693
  shmem_free_in_core_inode+0x63/0xb0 mm/shmem.c:3640
  i_callback+0x44/0x80 fs/inode.c:216
  __rcu_reclaim kernel/rcu/rcu.h:222 [inline]
  rcu_do_batch kernel/rcu/tree.c:2114 [inline]
  rcu_core+0x67f/0x1580 kernel/rcu/tree.c:2314
  rcu_core_si+0x9/0x10 kernel/rcu/tree.c:2323
  __do_softirq+0x262/0x98c kernel/softirq.c:292

The buggy address belongs to the object at ffff8880a5cf2a90
  which belongs to the cache shmem_inode_cache(17:syz0) of size 1192
The buggy address is located 448 bytes inside of
  1192-byte region [ffff8880a5cf2a90, ffff8880a5cf2f38)
The buggy address belongs to the page:
page:ffffea0002973c80 refcount:1 mapcount:0 mapping:ffff88808e1418c0  
index:0xffff8880a5cf2ffd
flags: 0x1fffc0000000200(slab)
raw: 01fffc0000000200 ffffea0002592ec8 ffffea0002492588 ffff88808e1418c0
raw: ffff8880a5cf2ffd ffff8880a5cf2040 0000000100000003 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff8880a5cf2b00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8880a5cf2b80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ffff8880a5cf2c00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                                  ^
  ffff8880a5cf2c80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8880a5cf2d00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

