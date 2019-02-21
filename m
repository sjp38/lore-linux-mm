Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA011C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 19:36:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60DBE2077B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 19:36:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60DBE2077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C17BD8E00A5; Thu, 21 Feb 2019 14:36:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC73A8E009E; Thu, 21 Feb 2019 14:36:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8FFB8E00A5; Thu, 21 Feb 2019 14:36:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63E6C8E009E
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 14:36:28 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b4so21047551plb.9
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 11:36:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Gb8z2lgqAiC6F+nD5n7Rzkgz8EGwT9MRBrddIqujyME=;
        b=HmYZQq/8A3Xv0jCsQoOnZBN4ysjYeuWp/T64qpD+L4tJoAhUp/ZrjDhFriJFBZUt4f
         aBHROBwJLSL+YhQ+kpiXBeg60Ca7lecF4RHc+4NyAq5VN5p2a/iUtF8jaRIOY+KnSSJ7
         Jnx3fQ6F4X49VuokzHN5vZcGP2pEFYwa21e8CMTyrr3LYkECLkTolBLFa1zCZ7ggUMfB
         xtVtDcUMrM0fZU7pt1e5nDK6+h5SvrNzR8E8uyTS8u4JWkgexiaSyLgIQrxeEFKM1tAa
         0ZSUgAjQxi1AjlHrmWYpMqATV0L8RzUbZRSLCSEsn3zxkWFBXosUgOKQAk75hrmMj31A
         1XFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuYzISWB8e53Ex4Vgvvo2Vqoff1ywimcYGXfqOKpdn2aJSRaj1qq
	CoaewyVu1+XucdSQjzYVr6asbc23tQ6YsD6D4x9GhOcXbsvwMhjwDX3y9Zx7CCf38Xqu5q0D6z6
	lc79kF8rhL4T0Rl+HgwlRK/3ub1fnWgZ04/Gzov2ltk4toTFvqKj7svTeIn67U9KhQw==
X-Received: by 2002:a63:b242:: with SMTP id t2mr121216pgo.451.1550777787940;
        Thu, 21 Feb 2019 11:36:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaiTWGDMXTQ0mscpeLoQGFvfj6PpiS9yDLmBVMcquh7reLYiocVBsg0of9M0YQv7EBp4mdU
X-Received: by 2002:a63:b242:: with SMTP id t2mr121163pgo.451.1550777786910;
        Thu, 21 Feb 2019 11:36:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550777786; cv=none;
        d=google.com; s=arc-20160816;
        b=MMJ59PDYfouuBqlY1F2LrzVyVhHfH57lNpxQWCLd96DqZevxhpMfy3NBrveqGg8yVZ
         fk7YO7ZAetRSsVMHgydIAniWRkEloVZP5LIi+geJUzUoR3/uPjW8YRghewLtczNhm7Sv
         ckK1CJvDA2IDxzY5NCgQjwvBnOjjkTteNk9w2oILj5ciEakVESb/smHY71LmgRIwrIdQ
         gfCS0vBbpe5GgVvGiM1KURPehWe0bERg64D2OzvU7foV1y74WO4qBdI+cTwddG7MNgl2
         vRMOKshWyDJUAaZbr1FscBb4ssMiL5ZXigYYlniWIAKu97jqdYcBzYXlMJo+Z1tOACPZ
         9n9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=Gb8z2lgqAiC6F+nD5n7Rzkgz8EGwT9MRBrddIqujyME=;
        b=UpgqkhjV9/ZnHrd0zj3OqHx+fGMxdOMRUtU6ZMVIEguWpAW4YZO+r+xDxPLshaQAC7
         rhuG0g2yEkbg71kygqZQFBlFLr2pRylFV7txlFg3NXtsd+CozduLZXyOBW49taXRs6QU
         ozWJPhubNO7lzQhULdCkfbIKRY+MWJ1CIObfdClnf/Xlc4DKx2Qsz6aUOg7V9Mu2cVec
         LTQxEYfQzguY+pkOvU3a80q/yXuEI0wls5ZqSthPOJiDlPDi7Vh+eYClm69rEhE4Bbpa
         5ooDQXNbgkSVuAjtvincpMNMA7B6GNIuNL3APcT1gb+WZC/aplvj4DrjI+w4roORBBQw
         o04g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h3si16837141pgl.468.2019.02.21.11.36.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 11:36:26 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id E44E33B90;
	Thu, 21 Feb 2019 19:36:25 +0000 (UTC)
Date: Thu, 21 Feb 2019 11:36:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com>
Cc: amir73il@gmail.com, darrick.wong@oracle.com, david@fromorbit.com,
 hannes@cmpxchg.org, hughd@google.com, jrdr.linux@gmail.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 syzkaller-bugs@googlegroups.com, willy@infradead.org, Jan Kara
 <jack@suse.cz>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 __generic_file_write_iter
Message-Id: <20190221113624.284fe267e73752639186a563@linux-foundation.org>
In-Reply-To: <0000000000001aab8b0582689e11@google.com>
References: <0000000000001aab8b0582689e11@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Feb 2019 06:52:04 -0800 syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com> wrote:

> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    4aa9fc2a435a Revert "mm, memory_hotplug: initialize struct..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=1101382f400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=4fceea9e2d99ac20
> dashboard link: https://syzkaller.appspot.com/bug?extid=ca95b2b7aef9e7cbd6ab
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> 
> Unfortunately, I don't have any reproducer for this crash yet.

Not understanding.  That seems to be saying that we got a NULL pointer
deref in __generic_file_write_iter() at

                written = generic_perform_write(file, from, iocb->ki_pos);

which isn't possible.

I'm not seeing recent changes in there which could have caused this.  Help.


> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
> #PF error: [INSTR]
> PGD a7ea0067 P4D a7ea0067 PUD 81535067 PMD 0
> Oops: 0010 [#1] PREEMPT SMP KASAN
> CPU: 0 PID: 15924 Comm: syz-executor0 Not tainted 5.0.0-rc4+ #50
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
> Google 01/01/2011
> RIP: 0010:          (null)
> Code: Bad RIP value.
> RSP: 0018:ffff88804c3d7858 EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffffffff885aeb60 RCX: 000000000000005b
> RDX: 0000000000000000 RSI: ffff88807ec22930 RDI: ffff8880a59bdcc0
> RBP: ffff88804c3d79b8 R08: 0000000000000000 R09: ffff88804c3d7910
> R10: ffff8880835ca200 R11: 0000000000000000 R12: 000000000000005b
> R13: ffff88804c3d7c98 R14: dffffc0000000000 R15: 0000000000000000
> FS:  00007f3456db4700(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: ffffffffffffffd6 CR3: 00000000814ac000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>   __generic_file_write_iter+0x25e/0x630 mm/filemap.c:3333
>   ext4_file_write_iter+0x37a/0x1410 fs/ext4/file.c:266
>   call_write_iter include/linux/fs.h:1862 [inline]
>   new_sync_write fs/read_write.c:474 [inline]
>   __vfs_write+0x764/0xb40 fs/read_write.c:487
>   vfs_write+0x20c/0x580 fs/read_write.c:549
>   ksys_write+0x105/0x260 fs/read_write.c:598
>   __do_sys_write fs/read_write.c:610 [inline]
>   __se_sys_write fs/read_write.c:607 [inline]
>   __x64_sys_write+0x73/0xb0 fs/read_write.c:607
>   do_syscall_64+0x1a3/0x800 arch/x86/entry/common.c:290
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x458089
> Code: 6d b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
> 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
> ff 0f 83 3b b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> RSP: 002b:00007f3456db3c78 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000000458089
> RDX: 000000000000005b RSI: 0000000020000240 RDI: 0000000000000003
> RBP: 000000000073bf00 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 00007f3456db46d4
> R13: 00000000004c7450 R14: 00000000004dce68 R15: 00000000ffffffff
> Modules linked in:
> CR2: 0000000000000000
> ---[ end trace 5cac9d2c75a59916 ]---
> kobject: 'loop5' (000000004426a409): kobject_uevent_env
> RIP: 0010:          (null)
> Code: Bad RIP value.
> RSP: 0018:ffff88804c3d7858 EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffffffff885aeb60 RCX: 000000000000005b
> kobject: 'loop5' (000000004426a409): fill_kobj_path: path  
> = '/devices/virtual/block/loop5'
> RDX: 0000000000000000 RSI: ffff88807ec22930 RDI: ffff8880a59bdcc0
> kobject: 'loop2' (00000000b82e0c58): kobject_uevent_env
> kobject: 'loop2' (00000000b82e0c58): fill_kobj_path: path  
> = '/devices/virtual/block/loop2'
> RBP: ffff88804c3d79b8 R08: 0000000000000000 R09: ffff88804c3d7910
> R10: ffff8880835ca200 R11: 0000000000000000 R12: 000000000000005b
> R13: ffff88804c3d7c98 R14: dffffc0000000000 R15: 0000000000000000
> kobject: 'loop5' (000000004426a409): kobject_uevent_env
> FS:  00007f3456db4700(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
> kobject: 'loop5' (000000004426a409): fill_kobj_path: path  
> = '/devices/virtual/block/loop5'
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000022029a0 CR3: 00000000814ac000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> 
> 
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
> 
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
> syzbot.

