Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68A3CC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 22:38:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C1D020856
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 22:38:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C1D020856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B80A66B02B5; Wed, 21 Aug 2019 18:38:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B31B86B02B6; Wed, 21 Aug 2019 18:38:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F99B6B02B7; Wed, 21 Aug 2019 18:38:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1F76B02B5
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:38:10 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 30C118248AA7
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 22:38:10 +0000 (UTC)
X-FDA: 75847899540.09.vein14_d12d04492046
X-HE-Tag: vein14_d12d04492046
X-Filterd-Recvd-Size: 6105
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 22:38:09 +0000 (UTC)
Received: by mail-io1-f69.google.com with SMTP id e20so4171864ioe.12
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:38:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:date:message-id:subject:from:to;
        bh=jBsYp09/cLeBSkbIbxHgzYI7ddEGG6UPk+vEQ8x/yJE=;
        b=mHKppFnQZbvsC0hVyB/02wrS3z56MaLWpHjua2qasaqdmrPESKXarNs0zybi33RiJA
         DK0mD+SNKQ+u7GR6oM/ffyiCg2W90uUwdLIWxEPaNBmmlxa6cU73vl8oDnTWPZ/RpJOK
         afRkxs1pUeETDLDMdeatPhFCq2j6/mjBm7kEhh+T6HMsFGO7HOa2GxsoqQH24CQ/YC4a
         CrvvjVh+A3jxMCbx9jsGvZcopLOMbqGSeP56r+ITAM8Cg2RxKRk+CgVFhVfKsNHwbrMO
         uJVIPEXbgJrvWY1qx9g4NVA6i0QFovFpfnVRXWeqhTlRUolvcMvTp9liRpYdJsgeiFzg
         4aNg==
X-Gm-Message-State: APjAAAX40FI2JPaFnjP9zYRf8JEIZFw96mztuJiaqOUj7SNFk1lJT4T+
	0iFSU12hZwvUBv7SjpiRD3ZQGkMp1irafkQKrMA7WhGT9xrm
X-Google-Smtp-Source: APXvYqzavPFlUWhnFmdpVUObRjYgw6MY/e5tU+JIj+9wrZ+1vCE20RJd43jMnxmak3ET8Jl7AtG2e2W+aGjEDZ9eNa/+0s/Sas+4
MIME-Version: 1.0
X-Received: by 2002:a6b:c8cf:: with SMTP id y198mr10240574iof.202.1566427089150;
 Wed, 21 Aug 2019 15:38:09 -0700 (PDT)
Date: Wed, 21 Aug 2019 15:38:09 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000003728c00590a83aa5@google.com>
Subject: WARNING: bad usercopy in hidraw_ioctl
From: syzbot <syzbot+fc7106c3bcd1cb7b165c@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, andreyknvl@google.com, cai@lca.pw, 
	isaacm@codeaurora.org, keescook@chromium.org, kstewart@linuxfoundation.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-usb@vger.kernel.org, 
	psodagud@codeaurora.org, syzkaller-bugs@googlegroups.com, tglx@linutronix.de
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    eea39f24 usb-fuzzer: main usb gadget fuzzer driver
git tree:       https://github.com/google/kasan.git usb-fuzzer
console output: https://syzkaller.appspot.com/x/log.txt?x=128c664c600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=d0c62209eedfd54e
dashboard link: https://syzkaller.appspot.com/bug?extid=fc7106c3bcd1cb7b165c
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+fc7106c3bcd1cb7b165c@syzkaller.appspotmail.com

------------[ cut here ]------------
Bad or missing usercopy whitelist? Kernel memory exposure attempt detected  
from SLUB object 'shmem_inode_cache' (offset 88, size 33)!
WARNING: CPU: 0 PID: 3101 at mm/usercopy.c:74 usercopy_warn+0xe8/0x110  
mm/usercopy.c:74
Kernel panic - not syncing: panic_on_warn set ...
CPU: 0 PID: 3101 Comm: syz-executor.0 Not tainted 5.3.0-rc5+ #28
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
RIP: 0010:usercopy_warn+0xe8/0x110 mm/usercopy.c:74
Code: e8 bd f8 d6 ff 49 89 e9 4c 89 e1 48 89 de 41 57 48 c7 c7 40 f5 cd 85  
41 55 41 56 4c 8b 44 24 20 48 8b 54 24 18 e8 9d de ac ff <0f> 0b 48 83 c4  
18 e9 45 ff ff ff 48 c7 c5 40 f3 cd 85 49 89 ee 49
RSP: 0018:ffff8881c5d07be8 EFLAGS: 00010282
RAX: 0000000000000000 RBX: ffffffff85cdf500 RCX: 0000000000000000
RDX: 0000000000008303 RSI: ffffffff81288cfd RDI: ffffed1038ba0f6f
RBP: ffffffff85cc2ca0 R08: ffff8881c79b0000 R09: ffffed103b645d58
R10: ffffed103b645d57 R11: ffff8881db22eabf R12: ffffffff86a6b0c8
R13: 0000000000000058 R14: ffffffff85cdf380 R15: 0000000000000021
  check_heap_object mm/usercopy.c:234 [inline]
  __check_object_size mm/usercopy.c:280 [inline]
  __check_object_size+0x327/0x39a mm/usercopy.c:250
  check_object_size include/linux/thread_info.h:119 [inline]
  check_copy_size include/linux/thread_info.h:150 [inline]
  copy_to_user include/linux/uaccess.h:151 [inline]
  hidraw_ioctl+0x65f/0xae0 drivers/hid/hidraw.c:440
  vfs_ioctl fs/ioctl.c:46 [inline]
  file_ioctl fs/ioctl.c:509 [inline]
  do_vfs_ioctl+0xd2d/0x1330 fs/ioctl.c:696
  ksys_ioctl+0x9b/0xc0 fs/ioctl.c:713
  __do_sys_ioctl fs/ioctl.c:720 [inline]
  __se_sys_ioctl fs/ioctl.c:718 [inline]
  __x64_sys_ioctl+0x6f/0xb0 fs/ioctl.c:718
  do_syscall_64+0xb7/0x580 arch/x86/entry/common.c:296
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x459829
Code: fd b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 cb b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f75e27c6c78 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000000459829
RDX: 00000000200000c0 RSI: 0000000080404804 RDI: 0000000000000003
RBP: 000000000075bfc8 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007f75e27c76d4
R13: 00000000004c21c9 R14: 00000000004d5628 R15: 00000000ffffffff
Kernel Offset: disabled
Rebooting in 86400 seconds..


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

