Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99E8DC3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 17:00:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5155C2332A
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 17:00:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ou25kIOk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5155C2332A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F14F36B0323; Wed, 21 Aug 2019 13:00:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEBB66B0324; Wed, 21 Aug 2019 13:00:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB2FA6B0325; Wed, 21 Aug 2019 13:00:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0113.hostedemail.com [216.40.44.113])
	by kanga.kvack.org (Postfix) with ESMTP id B88796B0323
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 13:00:35 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5B8BC181AC9C6
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 17:00:35 +0000 (UTC)
X-FDA: 75847048830.19.join89_797bbab92065a
X-HE-Tag: join89_797bbab92065a
X-Filterd-Recvd-Size: 7702
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 17:00:34 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id 4so1633643pld.10
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:00:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RsU08W9/afBmJ4GcGvCken8lWY/T5/5fZJ/HC8LpvYw=;
        b=ou25kIOk9sINCo+3cRDcGt9yjLpvoQY0j1yl/H2/yK9357uz8Cus+F4SpUSuxcZXBL
         +49O9FCuBVg8Kh48VfFTfWp2R8+fEYD+sevlBmUSbH83rSMnEqdKTzan8xGq8k/TaZeU
         8DY43QLs4OgwW6rtiVlf4cwz+Fgx6NkDbbkVlQTBwHNizXvE8zqxZjYN97l1dS9suvOH
         bMlpyHJO7dVxZcjL+0x6Kxyx/EYmfCPebZDcsEwsXgF5NvnSyLErqaeHuL9b27S0sTH2
         1+DtBOILGq5e7/CEFiG6MvEa7khudljkYq46qcjJkINp6J8jukq1BmV0O4HC+NxviLD1
         AliQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=RsU08W9/afBmJ4GcGvCken8lWY/T5/5fZJ/HC8LpvYw=;
        b=sRx2E75t79lxQ45OkOLy1wy3x9Qp1gqQZEhTL3S7iYVOWjj9NcjoCsHuej4fSubfr7
         ICLf6C9tKV0h2dkVuun6kXHW8++NW9OfTjhJq5EBcGGmcOzWtcbpaCpEKljTx4GrU7zq
         TaG6Ccx+kx64BRZS0ibnisTJpU4ezuV5LzRvrc/dXgG6trvLyt3cYAF8VyPSKkebYIlg
         p/WOBnsK1ae7Mj1Yh4xeX0HGVickDeS9gCC67wkUqy8hq50DgrauHj6y01l9wMQ1PISk
         S2d862Cqkt7gnbmPHsE05Zv+dt5GHKm7OVlBBvbeSWXG/kPdYJf/V0WH3eZC80tjzOzU
         0PKQ==
X-Gm-Message-State: APjAAAWkzdrDE+AYsROZxDOb5bKRPdMk7T98W5xx20WCTgesdz7KrvHe
	0Jzxn2DkFBMdnaAQfmSKYZSd1JII+lVRM3avcfsGEA==
X-Google-Smtp-Source: APXvYqy+5iaT7vro4zo8iyqIckXxgCTLhKcz3TBCgi/0JRfYsfYktT9XaTKZC22WeVRvW2OWrR/HksMeHNFxaPHpGWg=
X-Received: by 2002:a17:902:ab96:: with SMTP id f22mr35670775plr.147.1566406833279;
 Wed, 21 Aug 2019 10:00:33 -0700 (PDT)
MIME-Version: 1.0
References: <000000000000ce6527058f8bf0d0@google.com>
In-Reply-To: <000000000000ce6527058f8bf0d0@google.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 21 Aug 2019 19:00:21 +0200
Message-ID: <CAAeHK+yu=bN-HW-bgJ1OS3TDWpiieGi0Z5sbOuBYU2W=7CyNhQ@mail.gmail.com>
Subject: Re: BUG: bad usercopy in hidraw_ioctl
To: syzbot <syzbot+3de312463756f656b47d@syzkaller.appspotmail.com>
Cc: allison@lohutok.net, Qian Cai <cai@lca.pw>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, USB list <linux-usb@vger.kernel.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 7, 2019 at 9:28 PM syzbot
<syzbot+3de312463756f656b47d@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    e96407b4 usb-fuzzer: main usb gadget fuzzer driver
> git tree:       https://github.com/google/kasan.git usb-fuzzer
> console output: https://syzkaller.appspot.com/x/log.txt?x=151b2926600000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=cfa2c18fb6a8068e
> dashboard link: https://syzkaller.appspot.com/bug?extid=3de312463756f656b47d
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
>
> Unfortunately, I don't have any reproducer for this crash yet.
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+3de312463756f656b47d@syzkaller.appspotmail.com
>
> usercopy: Kernel memory exposure attempt detected from wrapped address
> (offset 0, size 0)!
> ------------[ cut here ]------------
> kernel BUG at mm/usercopy.c:98!
> invalid opcode: 0000 [#1] SMP KASAN
> CPU: 1 PID: 2968 Comm: syz-executor.1 Not tainted 5.3.0-rc2+ #25
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:usercopy_abort+0xb9/0xbb mm/usercopy.c:98
> Code: e8 c1 f7 d6 ff 49 89 d9 4d 89 e8 4c 89 e1 41 56 48 89 ee 48 c7 c7 e0
> f3 cd 85 ff 74 24 08 41 57 48 8b 54 24 20 e8 15 98 c1 ff <0f> 0b e8 95 f7
> d6 ff e8 80 9f fd ff 8b 54 24 04 49 89 d8 4c 89 e1
> RSP: 0018:ffff8881b0f37be8 EFLAGS: 00010282
> RAX: 000000000000005a RBX: ffffffff85cdf100 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: ffffffff8128a0fd RDI: ffffed10361e6f6f
> RBP: ffffffff85cdf2c0 R08: 000000000000005a R09: ffffed103b665d58
> R10: ffffed103b665d57 R11: ffff8881db32eabf R12: ffffffff85cdf460
> R13: ffffffff85cdf100 R14: 0000000000000000 R15: ffffffff85cdf100
> FS:  00007f539a2a9700(0000) GS:ffff8881db300000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000021237d0 CR3: 00000001d6ac6000 CR4: 00000000001406e0
> Call Trace:
>   check_bogus_address mm/usercopy.c:151 [inline]
>   __check_object_size mm/usercopy.c:260 [inline]
>   __check_object_size.cold+0xb2/0xba mm/usercopy.c:250
>   check_object_size include/linux/thread_info.h:119 [inline]
>   check_copy_size include/linux/thread_info.h:150 [inline]
>   copy_to_user include/linux/uaccess.h:151 [inline]
>   hidraw_ioctl+0x38c/0xae0 drivers/hid/hidraw.c:392
>   vfs_ioctl fs/ioctl.c:46 [inline]
>   file_ioctl fs/ioctl.c:509 [inline]
>   do_vfs_ioctl+0xd2d/0x1330 fs/ioctl.c:696
>   ksys_ioctl+0x9b/0xc0 fs/ioctl.c:713
>   __do_sys_ioctl fs/ioctl.c:720 [inline]
>   __se_sys_ioctl fs/ioctl.c:718 [inline]
>   __x64_sys_ioctl+0x6f/0xb0 fs/ioctl.c:718
>   do_syscall_64+0xb7/0x580 arch/x86/entry/common.c:296
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x459829
> Code: fd b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7
> 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff
> ff 0f 83 cb b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> RSP: 002b:00007f539a2a8c78 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000000459829
> RDX: 0000000020000800 RSI: 0000000090044802 RDI: 0000000000000004
> RBP: 000000000075c268 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 00007f539a2a96d4
> R13: 00000000004c21f3 R14: 00000000004d55b8 R15: 00000000ffffffff
> Modules linked in:
> ---[ end trace 24b9968555bf4653 ]---
> RIP: 0010:usercopy_abort+0xb9/0xbb mm/usercopy.c:98
> Code: e8 c1 f7 d6 ff 49 89 d9 4d 89 e8 4c 89 e1 41 56 48 89 ee 48 c7 c7 e0
> f3 cd 85 ff 74 24 08 41 57 48 8b 54 24 20 e8 15 98 c1 ff <0f> 0b e8 95 f7
> d6 ff e8 80 9f fd ff 8b 54 24 04 49 89 d8 4c 89 e1
> RSP: 0018:ffff8881b0f37be8 EFLAGS: 00010282
> RAX: 000000000000005a RBX: ffffffff85cdf100 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: ffffffff8128a0fd RDI: ffffed10361e6f6f
> RBP: ffffffff85cdf2c0 R08: 000000000000005a R09: ffffed103b665d58
> R10: ffffed103b665d57 R11: ffff8881db32eabf R12: ffffffff85cdf460
> R13: ffffffff85cdf100 R14: 0000000000000000 R15: ffffffff85cdf100
> FS:  00007f539a2a9700(0000) GS:ffff8881db300000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000021237d0 CR3: 00000001d6ac6000 CR4: 00000000001406e0
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

Looks like the same bug:

#syz dup: KASAN: slab-out-of-bounds Read in hidraw_ioctl

