Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19839C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:42:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B71A7214D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:42:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B71A7214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E3478E0003; Mon, 11 Mar 2019 16:42:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1916E8E0002; Mon, 11 Mar 2019 16:42:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A8A18E0003; Mon, 11 Mar 2019 16:42:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id D72508E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:42:08 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id x87so448517ita.1
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:42:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=bItM+VRk6jJF0KAwdaT1c7fAc/vef/B+nUNuBS5+Pws=;
        b=gheqdhKcWfu8AQJqA87Byy3q8nk8Tx9+FvzxcnQS+GgL7DIKAVdDV7AGiMFtan1kh9
         1ycCZbjX/Vzv/Wo085zmvx2HoCgDAxa8nC5FugRJxzENLwdbB3dO0BFEgzZ2m9LgPJV0
         jxe4PfB6A944/aFj4rc5fKxAL3H+ZJS96/Q8ZGDexsxORq+WMwIYaRVQNu8PEwog0M+/
         RZLFX3pky/xOT2iouvX9e1K8yFFh23m0SDdODF0FiJbKLRQAVJKNlgns8pvllNondqyS
         BJLtVWtZnjCIG9FY149ape0fN4J5IzjYK6OPXpzhcn+XEJhwyzMYDSFV77pFHtxPbHeR
         ntcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3hsigxakbalmlrsdteexktiibw.zhhzexnlxkvhgmxgm.vhf@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3HsiGXAkbALMlrsdTeeXkTiibW.ZhhZeXnlXkVhgmXgm.Vhf@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAVg910zMpQi2ipojUg3q8BUP2VluZN6MRin1R83yJt+w8PpNgzh
	xindh2KCVIaPs7Hks+ShRZVfPdVJfrmthMVWeHIvQNt9YTbqq2WA9Ojz28jdq8iocCU6deHCzDH
	jALVjwp3V3357aQVOUzaTRfdoP5NQIoXS4Su6VClfIZ+by3/h+N6u6fOKt8VEFhKfeEsIpohwJc
	9k0RyHADmeKQQdY0Y2eT5oJpr4vMVR9Jq3MJhhW5x4JlnlbBkiD8FmAeHJChTAcS0r6NIumF0Z/
	G6R4FR5oufOD5bHep9NynTO5h6ojEfkOoHsHU6djGPboeJsv1RmqJexKMB0NsjOuch07aFQfCtq
	dT+WwI1oxU0YJlwHqEhCOtupMo28T9X5uCt2ZPf3eeeXDDWHz7K345JbEuLyl0I1+V19YeNR2w=
	=
X-Received: by 2002:a6b:4108:: with SMTP id n8mr18030028ioa.168.1552336928544;
        Mon, 11 Mar 2019 13:42:08 -0700 (PDT)
X-Received: by 2002:a6b:4108:: with SMTP id n8mr18029961ioa.168.1552336927096;
        Mon, 11 Mar 2019 13:42:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552336927; cv=none;
        d=google.com; s=arc-20160816;
        b=yDaONjlKyXntQHRV06sYKBoZQaA14PRHzE2786Pkt76f9vmKTrG8G0WrWPfuVFx01X
         5bgnUKTfmBQZmcxZN843Yse9QHU+nvH4L2dQw4cS8NEu+r/vht4m2H3+X7azBObWJg3M
         76n6X+0RoLn5kmSVNApxQ4wfeJlg6EGdmHQvPaaVtoIv5RyRYL9pOzwO3e4G9+4JR8GX
         XKO7614BzAXQY2TBdk/onbgoZT5G+ClZ3lgxYLqFnmfg9qKUpbR2cmwhRM8V8Amh0n7p
         aTO3UOLuvEfynDeEGcxsPuQRsvGP3wWTFz2R/uodMiq+Bw2TaVShO7TJnh+3HO1W9HQ5
         7JUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=bItM+VRk6jJF0KAwdaT1c7fAc/vef/B+nUNuBS5+Pws=;
        b=PZohYJWB4szuKgXiSiqN+ZrD7J7qBSKjLcl/U3M0kC+Zip3tyyrWjyTNvoEObZfltY
         0f3ldI4WCAj93xMgAt5lIwdpKnTi5FnchEY5LqBHPJtG63vrNVZgGHFZke1rOde3ZlrS
         xvNJ+BnAnv7Ir0bQTT7Xk1viQgkJJ+fJq9bvRf5UI3jS0cFmou0MHnMXlCEUN0jTzTN1
         AnhR7qPsw9pOyaZTUFNJ3GZ7fOyxPe31iX4eqrGe/GQW/XC03DYCqjuUU5EKqQ7waGY5
         wSbianb0qWI/ywlIaNyOKad1EoydfdWy5IwYN0l1Id6GnWcwSdi+yBNEzUYdRuge/qFb
         o7qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3hsigxakbalmlrsdteexktiibw.zhhzexnlxkvhgmxgm.vhf@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3HsiGXAkbALMlrsdTeeXkTiibW.ZhhZeXnlXkVhgmXgm.Vhf@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id h12sor482430itb.29.2019.03.11.13.42.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 13:42:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3hsigxakbalmlrsdteexktiibw.zhhzexnlxkvhgmxgm.vhf@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3hsigxakbalmlrsdteexktiibw.zhhzexnlxkvhgmxgm.vhf@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3HsiGXAkbALMlrsdTeeXkTiibW.ZhhZeXnlXkVhgmXgm.Vhf@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxbPIFr1Mfb5vjlLrjnAaO/Uk3TTLwwI3GHCJogGZoS8MRorcajooh7DH8IjMszM5kiN3kYiOQxFOdGwYpcKiGOAUyhdazG
MIME-Version: 1.0
X-Received: by 2002:a24:37c6:: with SMTP id r189mr45971itr.13.1552336926731;
 Mon, 11 Mar 2019 13:42:06 -0700 (PDT)
Date: Mon, 11 Mar 2019 13:42:06 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000016f7d40583d79bd9@google.com>
Subject: WARNING: bad usercopy in fanotify_read
From: syzbot <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, cai@lca.pw, crecklin@redhat.com, 
	keescook@chromium.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    12ad143e Merge branch 'perf-urgent-for-linus' of git://git..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=12776f57200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=e9d91b7192a5e96e
dashboard link: https://syzkaller.appspot.com/bug?extid=2c49971e251e36216d1f
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
userspace arch: amd64
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1287516f200000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17ee410b200000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com

------------[ cut here ]------------
Bad or missing usercopy whitelist? Kernel memory exposure attempt detected  
from SLAB object 'fanotify_event' (offset 40, size 8)!
WARNING: CPU: 1 PID: 7649 at mm/usercopy.c:78 usercopy_warn+0xeb/0x110  
mm/usercopy.c:78
Kernel panic - not syncing: panic_on_warn set ...
CPU: 1 PID: 7649 Comm: syz-executor381 Not tainted 5.0.0+ #17
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x172/0x1f0 lib/dump_stack.c:113
  panic+0x2cb/0x65c kernel/panic.c:214
  __warn.cold+0x20/0x45 kernel/panic.c:571
  report_bug+0x263/0x2b0 lib/bug.c:186
  fixup_bug arch/x86/kernel/traps.c:179 [inline]
  fixup_bug arch/x86/kernel/traps.c:174 [inline]
  do_error_trap+0x11b/0x200 arch/x86/kernel/traps.c:272
  do_invalid_op+0x37/0x50 arch/x86/kernel/traps.c:291
  invalid_op+0x14/0x20 arch/x86/entry/entry_64.S:973
RIP: 0010:usercopy_warn+0xeb/0x110 mm/usercopy.c:78
Code: c8 e8 d9 88 c0 ff 4c 8b 45 c0 4d 89 e9 4c 89 e1 48 8b 55 c8 41 57 48  
89 de 48 c7 c7 e0 dc 74 87 ff 75 d0 41 56 e8 03 4b 93 ff <0f> 0b 48 83 c4  
18 e9 46 ff ff ff 49 c7 c5 e0 da 74 87 4d 89 ee 4d
RSP: 0018:ffff8880a417fb18 EFLAGS: 00010282
RAX: 0000000000000000 RBX: ffffffff8774dca0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff815ad7b6 RDI: ffffed101482ff55
RBP: ffff8880a417fb70 R08: ffff888088d78580 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff8859408d
R13: ffffffff8775d500 R14: ffffffff8774db20 R15: 0000000000000008
  __check_heap_object+0x88/0xb3 mm/slab.c:4453
  check_heap_object mm/usercopy.c:238 [inline]
  __check_object_size mm/usercopy.c:284 [inline]
  __check_object_size+0x342/0x42f mm/usercopy.c:254
  check_object_size include/linux/thread_info.h:119 [inline]
  check_copy_size include/linux/thread_info.h:150 [inline]
  copy_to_user include/linux/uaccess.h:151 [inline]
  copy_fid_to_user fs/notify/fanotify/fanotify_user.c:236 [inline]
  copy_event_to_user fs/notify/fanotify/fanotify_user.c:294 [inline]
  fanotify_read+0xde0/0x1430 fs/notify/fanotify/fanotify_user.c:362
  __vfs_read+0x8d/0x110 fs/read_write.c:416
  vfs_read+0x194/0x3e0 fs/read_write.c:452
  ksys_read+0xea/0x1f0 fs/read_write.c:578
  __do_sys_read fs/read_write.c:588 [inline]
  __se_sys_read fs/read_write.c:586 [inline]
  __x64_sys_read+0x73/0xb0 fs/read_write.c:586
  do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x4456b9
Code: e8 6c b6 02 00 48 83 c4 18 c3 0f 1f 80 00 00 00 00 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 2b 12 fc ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007fb296f31db8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
RAX: ffffffffffffffda RBX: 00000000006dac28 RCX: 00000000004456b9
RDX: 000000000000006b RSI: 0000000020000000 RDI: 0000000000000004
RBP: 00000000006dac20 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000006dac2c
R13: 00007ffd8eb3d16f R14: 00007fb296f329c0 R15: 20c49ba5e353f7cf
Kernel Offset: disabled
Rebooting in 86400 seconds..


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

