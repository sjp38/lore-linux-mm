Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11F34C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:56:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C62052086C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:56:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C62052086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 567DF8E0002; Wed, 13 Feb 2019 12:56:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 516FA8E0001; Wed, 13 Feb 2019 12:56:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42BC08E0002; Wed, 13 Feb 2019 12:56:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC468E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:56:06 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id f137so5153296ita.7
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:56:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=tGpGGv9zZPSYd1bawqbNQ+HgCFaseK+m9nbLFgTQS/k=;
        b=dUAj6swTyCfouZNd3xVXdUGw/bXiWOO3ESKzDWtorUoyNYkOE/wO8ZOZeGC3T3i4L9
         dcGVgRdLDFUvXQhPyU0HTtDVTGKYbHaQmqondVrSPX9DbK9pFTiHUnlbH08ioC/DHqr+
         mkRoxay6XJOoj1UgYGGxJF4h1KHETKouxeN6F2tkVctkJOG2v2qI4ylqZg1CibzIJX6/
         b6Q9GIf0QtyjmFRr2nuGrAtZKu0NUIzseiSioplZof2DQrtauWTw8YHhqjUvVQUF8KO0
         MpNuzMd5hyX7MxyWt+0PRUbv3YXcoWzISjHA68tBb6abdN0Q1CNew43fK4NQR0Rz2aki
         nFnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3nfpkxakbagmtzalbmmfsbqqje.hpphmfvtfsdpoufou.dpn@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3NFpkXAkbAGMTZaLBMMFSBQQJE.HPPHMFVTFSDPOUFOU.DPN@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AHQUAuY4NkkQ1NPOE28MGdoa9w8aQa0szgfRCZhj7F9jmUqHwd/Qpv+O
	372009qGrJe3jjgb8Q2L1dJKmF6UdhtsvCSqggQTqTHazd3F70vCxji+psFxNRYxRbSVf0bbafQ
	cExkVn3qXPRr5b7wRFHjSWF3uZwKOGYIpSruMNsiqjufK0IUyplHXKcRrXuiMTWQ/8WRt7ncf/0
	TZgVwHr2Ekb13NmCn81hLa87wkiivqCQB7gSKFBiGLq1MiepCyOjr9o+YUvUedTUhlbAPDg7mgB
	zWiqhQD4aghr68ZJ3ATBplTvPTZjQLa/znQ9GjRL7I5FwWHpFHYjQCAjjQ9f6w6svJfvA+Zo7zl
	SZ1apmTaGbjLLHnxBa9epKuh1b5UBESyl9ny6QDe9p2vYvuTOPMxT/xA9x1NoDzOGW90Nh76DA=
	=
X-Received: by 2002:a5d:948a:: with SMTP id v10mr993572ioj.189.1550080565825;
        Wed, 13 Feb 2019 09:56:05 -0800 (PST)
X-Received: by 2002:a5d:948a:: with SMTP id v10mr993533ioj.189.1550080564727;
        Wed, 13 Feb 2019 09:56:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550080564; cv=none;
        d=google.com; s=arc-20160816;
        b=OA88p3bqL5XgoXfvb99TEtkljmWmuNEAL9k4GX7o5Spbyd3dsKICKo+sVfNUiQhb5a
         KvIJREcdXM52YxT7FdAKAlrNDQbjMbyBueEaBXK9AWZGmqATsS4KA5jTZT0jqCxfg33k
         v5jCaiuktacVZIskrep7Hn5ab1XnCXDFZYrqEqnrvI116S+X8aSDCDiFOh2XhVD6O2tk
         DxAtZoJfFZUio7/IGdH6E51kCIsORtHPg77j3n/bpXzbXetEAs3H8dpoiHkHz7AVbhJj
         SjzqJ9GDljVyZnGrlgiyynhGJOIwCoC/8jiTpxwSsoj0bQk97Ms7E83eiFdMrhH7x9Cr
         BXlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=tGpGGv9zZPSYd1bawqbNQ+HgCFaseK+m9nbLFgTQS/k=;
        b=hzcTTc+Ql3gVXJY5Tc2Pm9DWIl08pZBbLzEg877EzvyrLm973O11OwGN0cEFQNblVY
         5zjguz8j+2bGMzrmiHMclOYSEpMfuuABC8EfmEsssGCiQfdESBXCS7104W6AU9eNNAfT
         6ylzbimOol5wFiwVQBRULAR6M41rSHyeUDV9eb5+/0cqD93qZgMxLgE3pwF857Ybh9nK
         64uuwLiJa8G+T15e6p4uPje+q3yxGZSDYUs+RxFstijpa97c4NEF25Uuifejf0dqwxof
         e+nVMfRm53PBnjwsSz8rSu9wzuHC7Q8L27IFhlMDfjemcgcMo/W53h1VuUz9w57L5k2S
         Q10A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3nfpkxakbagmtzalbmmfsbqqje.hpphmfvtfsdpoufou.dpn@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3NFpkXAkbAGMTZaLBMMFSBQQJE.HPPHMFVTFSDPOUFOU.DPN@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id l128sor8741946ioa.69.2019.02.13.09.56.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 09:56:04 -0800 (PST)
Received-SPF: pass (google.com: domain of 3nfpkxakbagmtzalbmmfsbqqje.hpphmfvtfsdpoufou.dpn@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3nfpkxakbagmtzalbmmfsbqqje.hpphmfvtfsdpoufou.dpn@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3NFpkXAkbAGMTZaLBMMFSBQQJE.HPPHMFVTFSDPOUFOU.DPN@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: AHgI3IYlS2NNcvSkEFyhiWkWuB1SpsLZPUaTYv4wgqwXTgMNfuhmJwGh2/8ElzFKHBUHzGJISgoHEvg8v3snZHXPN50689bvw1bo
MIME-Version: 1.0
X-Received: by 2002:a6b:510c:: with SMTP id f12mr1272016iob.16.1550080564397;
 Wed, 13 Feb 2019 09:56:04 -0800 (PST)
Date: Wed, 13 Feb 2019 09:56:04 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000006a12bd0581ca4145@google.com>
Subject: BUG: Bad page state (5)
From: syzbot <syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, 
	nborisov@suse.com, rppt@linux.vnet.ibm.com, shakeelb@google.com, 
	syzkaller-bugs@googlegroups.com, vbabka@suse.cz, willy@infradead.org
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    c4f3ef3eb53f Add linux-next specific files for 20190213
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=1130a124c00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=9ec67976eb2df882
dashboard link: https://syzkaller.appspot.com/bug?extid=2cd2887ea471ed6e6995
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14ecdaa8c00000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12ebe178c00000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+2cd2887ea471ed6e6995@syzkaller.appspotmail.com

BUG: Bad page state in process udevd  pfn:472f0
name:"memfd:"
page:ffffea00011cbc00 count:0 mapcount:0 mapping:ffff88800df2ad40 index:0xf
shmem_aops
flags: 0x1fffc000008000c(uptodate|dirty|swapbacked)
raw: 01fffc000008000c ffffea0000ac4f08 ffff8880a85af890 ffff88800df2ad40
raw: 000000000000000f 0000000000000000 00000000ffffffff 0000000000000000
page dumped because: non-NULL mapping
Modules linked in:
CPU: 1 PID: 7586 Comm: udevd Not tainted 5.0.0-rc6-next-20190213 #34
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x172/0x1f0 lib/dump_stack.c:113
  bad_page.cold+0xda/0xff mm/page_alloc.c:586
  free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1014
  free_pages_check mm/page_alloc.c:1023 [inline]
  free_pages_prepare mm/page_alloc.c:1113 [inline]
  free_pcp_prepare mm/page_alloc.c:1138 [inline]
  free_unref_page_prepare mm/page_alloc.c:2991 [inline]
  free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3060
name:"memfd:"
  release_pages+0x60d/0x1940 mm/swap.c:791
  pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
  __pagevec_lru_add mm/swap.c:917 [inline]
  lru_add_drain_cpu+0x2f7/0x520 mm/swap.c:581
  lru_add_drain+0x20/0x60 mm/swap.c:652
  exit_mmap+0x290/0x530 mm/mmap.c:3134
  __mmput kernel/fork.c:1047 [inline]
  mmput+0x15f/0x4c0 kernel/fork.c:1068
  exec_mmap fs/exec.c:1046 [inline]
  flush_old_exec+0x8d9/0x1c20 fs/exec.c:1279
  load_elf_binary+0x9bc/0x53f0 fs/binfmt_elf.c:864
  search_binary_handler fs/exec.c:1656 [inline]
  search_binary_handler+0x17f/0x570 fs/exec.c:1634
  exec_binprm fs/exec.c:1698 [inline]
  __do_execve_file.isra.0+0x1394/0x23f0 fs/exec.c:1818
  do_execveat_common fs/exec.c:1865 [inline]
  do_execve fs/exec.c:1882 [inline]
  __do_sys_execve fs/exec.c:1958 [inline]
  __se_sys_execve fs/exec.c:1953 [inline]
  __x64_sys_execve+0x8f/0xc0 fs/exec.c:1953
  do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x7fc7001ba207
Code: Bad RIP value.
RSP: 002b:00007ffe06aa13b8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007fc7001ba207
RDX: 0000000001fd5fd0 RSI: 00007ffe06aa14b0 RDI: 00007ffe06aa24c0
RBP: 0000000000625500 R08: 0000000000001c49 R09: 0000000000001c49
R10: 0000000000000000 R11: 0000000000000206 R12: 0000000001fd5fd0
R13: 0000000000000007 R14: 0000000001fc6250 R15: 0000000000000005
BUG: Bad page state in process udevd  pfn:2b13c
page:ffffea0000ac4f00 count:0 mapcount:0 mapping:ffff88800df2ad40 index:0xe
shmem_aops
flags: 0x1fffc000008000c(uptodate|dirty|swapbacked)
raw: 01fffc000008000c ffff8880a85af890 ffff8880a85af890 ffff88800df2ad40
raw: 000000000000000e 0000000000000000 00000000ffffffff 0000000000000000
page dumped because: non-NULL mapping
Modules linked in:
CPU: 1 PID: 7586 Comm: udevd Tainted: G    B              
5.0.0-rc6-next-20190213 #34
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x172/0x1f0 lib/dump_stack.c:113
  bad_page.cold+0xda/0xff mm/page_alloc.c:586
name:"memfd:"
  free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1014
  free_pages_check mm/page_alloc.c:1023 [inline]
  free_pages_prepare mm/page_alloc.c:1113 [inline]
  free_pcp_prepare mm/page_alloc.c:1138 [inline]
  free_unref_page_prepare mm/page_alloc.c:2991 [inline]
  free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3060
  release_pages+0x60d/0x1940 mm/swap.c:791
  pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
  __pagevec_lru_add mm/swap.c:917 [inline]
  lru_add_drain_cpu+0x2f7/0x520 mm/swap.c:581
  lru_add_drain+0x20/0x60 mm/swap.c:652
  exit_mmap+0x290/0x530 mm/mmap.c:3134
  __mmput kernel/fork.c:1047 [inline]
  mmput+0x15f/0x4c0 kernel/fork.c:1068
  exec_mmap fs/exec.c:1046 [inline]
  flush_old_exec+0x8d9/0x1c20 fs/exec.c:1279
  load_elf_binary+0x9bc/0x53f0 fs/binfmt_elf.c:864
  search_binary_handler fs/exec.c:1656 [inline]
  search_binary_handler+0x17f/0x570 fs/exec.c:1634
  exec_binprm fs/exec.c:1698 [inline]
  __do_execve_file.isra.0+0x1394/0x23f0 fs/exec.c:1818
  do_execveat_common fs/exec.c:1865 [inline]
  do_execve fs/exec.c:1882 [inline]
  __do_sys_execve fs/exec.c:1958 [inline]
  __se_sys_execve fs/exec.c:1953 [inline]
  __x64_sys_execve+0x8f/0xc0 fs/exec.c:1953
  do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x7fc7001ba207
Code: Bad RIP value.
RSP: 002b:00007ffe06aa13b8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007fc7001ba207
RDX: 0000000001fd5fd0 RSI: 00007ffe06aa14b0 RDI: 00007ffe06aa24c0
RBP: 0000000000625500 R08: 0000000000001c49 R09: 0000000000001c49
R10: 0000000000000000 R11: 0000000000000206 R12: 0000000001fd5fd0
R13: 0000000000000007 R14: 0000000001fc6250 R15: 0000000000000005


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

