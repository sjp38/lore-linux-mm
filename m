Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 215A7C4CECD
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 18:49:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEF6320665
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 18:49:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEF6320665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 886596B0003; Mon, 16 Sep 2019 14:49:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 836FB6B0006; Mon, 16 Sep 2019 14:49:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74B9E6B0007; Mon, 16 Sep 2019 14:49:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0210.hostedemail.com [216.40.44.210])
	by kanga.kvack.org (Postfix) with ESMTP id 543196B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:49:11 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B872C180AD802
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 18:49:10 +0000 (UTC)
X-FDA: 75941671260.20.hands99_6d31edfd07638
X-HE-Tag: hands99_6d31edfd07638
X-Filterd-Recvd-Size: 6269
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 18:49:10 +0000 (UTC)
Received: by mail-io1-f71.google.com with SMTP id j23so1108575iog.16
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:49:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:date:message-id:subject:from:to;
        bh=F5NQvrUFVwU+iYEomKDgHpNzH9BuzuG1Oq9cILqoF9w=;
        b=iHdLn+a9LNU2BQetUv6C9kO9VZM6SdD0zS7gB6L948ROov3Yp+AJwMmsmS2Gev+jgl
         eQXjwVJdofRSvYnx40W5MLZgp5eBlwHmra6hACdGtZIl7xgx3gHzoHKfMXGbLajQsfAI
         gqeM0o0LqYzhJ5o/uy4BFqohlwSYNoZDRTPljTPBr64IBMuZk8WbYAR5j0Rh82hlZ46K
         Brhv68IEAibDmml6Ad7+BgSVjMEDjwq0y2WN/cR098bCSPJ8rSQIeZICKAYF5clAEncv
         Ij+daD3K+xhkYEUPhRPRSLFwV0qn5ydZMlJ6D8JYXlk9UNFxCtgpitqw3JeQcyWLDXNW
         4zVA==
X-Gm-Message-State: APjAAAUqSa2ir0bdO+xrkHmN4gThFGpaUC3h3vgoMmJ2sLTYw4sR3S2N
	1uXy6YHAhV+dihbRqGabOBR2VA22cSMkWg3vvZyN0l/5+qUI
X-Google-Smtp-Source: APXvYqw3P64aFVztpt9L2rmR2DtHi9s6MW4xDKqLCr5gsOt4FQ/bH8ofPvnN+yxBVy6i+DOaBrafpW0wiKTu/tg1tSat6oibElQz
MIME-Version: 1.0
X-Received: by 2002:a6b:148b:: with SMTP id 133mr1540961iou.81.1568659749577;
 Mon, 16 Sep 2019 11:49:09 -0700 (PDT)
Date: Mon, 16 Sep 2019 11:49:09 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000025ae690592b00fbd@google.com>
Subject: WARNING in __alloc_pages_nodemask
From: syzbot <syzbot+e38fe539fedfc127987e@syzkaller.appspotmail.com>
To: aarcange@redhat.com, akpm@linux-foundation.org, andreyknvl@google.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-usb@vger.kernel.org, 
	mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, 
	vbabka@suse.cz, yang.shi@linux.alibaba.com, zhongjiang@huawei.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    f0df5c1b usb-fuzzer: main usb gadget fuzzer driver
git tree:       https://github.com/google/kasan.git usb-fuzzer
console output: https://syzkaller.appspot.com/x/log.txt?x=14b15371600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=5c6633fa4ed00be5
dashboard link: https://syzkaller.appspot.com/bug?extid=e38fe539fedfc127987e
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1093bed1600000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=1603cfc6600000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+e38fe539fedfc127987e@syzkaller.appspotmail.com

WARNING: CPU: 0 PID: 1720 at mm/page_alloc.c:4696  
__alloc_pages_nodemask+0x36f/0x780 mm/page_alloc.c:4696
Kernel panic - not syncing: panic_on_warn set ...
CPU: 0 PID: 1720 Comm: syz-executor388 Not tainted 5.3.0-rc7+ #0
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0xca/0x13e lib/dump_stack.c:113
  panic+0x2a3/0x6da kernel/panic.c:219
  __warn.cold+0x20/0x4a kernel/panic.c:576
  report_bug+0x262/0x2a0 lib/bug.c:186
  fixup_bug arch/x86/kernel/traps.c:179 [inline]
  fixup_bug arch/x86/kernel/traps.c:174 [inline]
  do_error_trap+0x12b/0x1e0 arch/x86/kernel/traps.c:272
  do_invalid_op+0x32/0x40 arch/x86/kernel/traps.c:291
  invalid_op+0x23/0x30 arch/x86/entry/entry_64.S:1028
RIP: 0010:__alloc_pages_nodemask+0x36f/0x780 mm/page_alloc.c:4696
Code: fe ff ff 65 48 8b 04 25 00 ef 01 00 48 05 60 10 00 00 41 be 01 00 00  
00 48 89 44 24 58 e9 ee fd ff ff 81 e5 00 20 00 00 75 02 <0f> 0b 45 31 f6  
e9 6b ff ff ff 8b 44 24 68 89 04 24 65 8b 2d e9 7e
RSP: 0018:ffff8881d320f9d8 EFLAGS: 00010046
RAX: 0000000000000000 RBX: 1ffff1103a641f3f RCX: 0000000000000000
RDX: 0000000000000000 RSI: dffffc0000000000 RDI: 0000000000040a20
RBP: 0000000000000000 R08: ffff8881d3bcc800 R09: ffffed103a541d19
R10: ffffed103a541d18 R11: ffff8881d2a0e8c7 R12: 0000000000000012
R13: 0000000000000012 R14: 0000000000000000 R15: ffff8881d2a0e8c0
  alloc_pages_current+0xff/0x200 mm/mempolicy.c:2153
  alloc_pages include/linux/gfp.h:509 [inline]
  kmalloc_order+0x1a/0x60 mm/slab_common.c:1257
  kmalloc_order_trace+0x18/0x110 mm/slab_common.c:1269
  __usbhid_submit_report drivers/hid/usbhid/hid-core.c:588 [inline]
  usbhid_submit_report+0x5b5/0xde0 drivers/hid/usbhid/hid-core.c:638
  usbhid_request+0x3c/0x70 drivers/hid/usbhid/hid-core.c:1252
  hid_hw_request include/linux/hid.h:1053 [inline]
  hiddev_ioctl+0x526/0x1550 drivers/hid/usbhid/hiddev.c:735
  vfs_ioctl fs/ioctl.c:46 [inline]
  file_ioctl fs/ioctl.c:509 [inline]
  do_vfs_ioctl+0xd2d/0x1330 fs/ioctl.c:696
  ksys_ioctl+0x9b/0xc0 fs/ioctl.c:713
  __do_sys_ioctl fs/ioctl.c:720 [inline]
  __se_sys_ioctl fs/ioctl.c:718 [inline]
  __x64_sys_ioctl+0x6f/0xb0 fs/ioctl.c:718
  do_syscall_64+0xb7/0x580 arch/x86/entry/common.c:296
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x444949
Code: e8 bc af 02 00 48 83 c4 18 c3 0f 1f 80 00 00 00 00 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 1b d8 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007fffed614ab8 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 00000000004002e0 RCX: 0000000000444949
RDX: 0000000020000080 RSI: 00000000400c4808 RDI: 0000000000000004
RBP: 00000000006cf018 R08: 18c1180b508ac6d9 R09: 00000000004002e0
R10: 000000000000000f R11: 0000000000000246 R12: 00000000004025f0
R13: 0000000000402680 R14: 0000000000000000 R15: 0000000000000000
Kernel Offset: disabled
Rebooting in 86400 seconds..


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

