Return-Path: <SRS0=02Vf=PI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94AE1C43387
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 07:49:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 465D92075D
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 07:49:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QkA/Or7E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 465D92075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDFA08E0083; Mon, 31 Dec 2018 02:49:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB5C58E005B; Mon, 31 Dec 2018 02:49:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA4168E0083; Mon, 31 Dec 2018 02:49:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD5D98E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 02:49:58 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id s25so31388157ioc.14
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 23:49:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7IifCV+hOWUZqSd3U7iPhvIkdMZehWr+5GNvcA2uEEw=;
        b=ISh/GC2V2xFWjMgiqjBhdwUtlXuc4LzHgDdri78Y88gc2Fx8RVQZr/ZMlgi0FI5xWQ
         y7X1gSHHZkz6zOOnICzrmHz++R/Gzhd4LUfZA/iFJ9YMphLOWQ7TtQXFxi8f7dIV8LTF
         IYnXCSb+rJKO424lzFiNdVOLK9ISM6OZ2Xu7Cy12bsfL8BywainP4pmedjtYz/Ku2c6l
         68SpQ/nlej1iFiOv9hJvbUKJkYdLoCl95bZ4rNGMtgQlWnOL+HCC+ig0lIaZGBA2nO+m
         EzRiHQInOc9MXiw7F7/zyVX2mFIJPFpZi4peml0bimzBOdvUz/LgBeyrw6YJbAFHzKwX
         ersg==
X-Gm-Message-State: AA+aEWahZtQb/gRtq9d0+BXLic1sax8HcAiZmFC+ZB1EoSECfbhCOYm2
	/npIUp3T6XLv6csMftKCtT/iwbuaHJ5nhEsIF4k7XnGIRZYDMNyXy6YBazsdwx4AhRNfnvQbfk7
	2hwxdcCVdkTesumq5PHPukSJhA4Anu7YPHSxcOfaBC5kpNiqFr86ZD+1QLY1j/KfoKnGyKCdEj9
	epe8/2Gasxu24DM84Z1p+yMBuWlpx5Z7LkqUR1sPB6SS4DIZII2zZaxWs5IJCxe4FgaJHOIiiGF
	lXyxbb3FT9v8AU8qec+V8Bj8eLaQrz1t+E1kLSAo2Zk4Z6nO7qCUlwzi47P7pNSblVyC++aILN0
	rHiFTh2TLiL0srlh2uyXm3EDep1StNIxDTfo8wdoFJZwRoxoiuVovcNi35eqkDjlRmdBcIaW+nr
	n
X-Received: by 2002:a24:248:: with SMTP id 69mr23142517itu.91.1546242598415;
        Sun, 30 Dec 2018 23:49:58 -0800 (PST)
X-Received: by 2002:a24:248:: with SMTP id 69mr23142498itu.91.1546242597727;
        Sun, 30 Dec 2018 23:49:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546242597; cv=none;
        d=google.com; s=arc-20160816;
        b=JegiuFgTht3hu+X7g5GcKbL9gjd8+76BXpb1h0cVtVvLAoXPE291HBvrnUpxpPs+eh
         W0IC5LbApaciWmj1j2tTDlSjCmxe8BdQsrObOs5ZcjLOScRyAW22zMCYtmuFne/MZAce
         lphH8adWvMKcLAR9oc8rTi+93szY6YHWOOFpKuBZOKikGrMQUCm4hOP7GU7RNitI4r70
         0YM7ENXUD1jgKpsWlEmDD2HHXNCoLhusn/xxK0oisoimnDWSovz+trN6ipSjpD2CmnAJ
         7Q84pQqSY37vvPKQdZfDLB0JhN63/xwYgf6nibbIfh6kRMm4EY62SNH6a3WnudyKegzd
         ZwaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7IifCV+hOWUZqSd3U7iPhvIkdMZehWr+5GNvcA2uEEw=;
        b=uv+sj9YbhDcqd3+1duMqZinzytmPUpQBVfUEIj4jXC/jQAXHLHYPsyOR1JDJahsUmj
         VGQBppR01jHT1PTWoNoZhozhVbXRa2w5P6g1HhvD1gOOqIMrnyQoIlzMWw7+IEvzYg5j
         a/B4mPbW/9iKAJnj1gpTqbj5yHEI5QbI2D1OteJ0/hXtnEINFpxLbpis65J7BlBVLjx0
         8fQz4m+BcNuquSW4uw8VvODsf9R3ALVaLIpi6MWctIKma55OMcOAOyslGl7yjVuSmejI
         8/05J8DG9bUVWcFC4IbGW3F7VWLhI8yU8yhLZZGOZBWHBPXTF2Hs8Fkne1Lmv0P5dt9v
         a+BQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="QkA/Or7E";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e14sor11259034ioh.3.2018.12.30.23.49.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 23:49:57 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="QkA/Or7E";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7IifCV+hOWUZqSd3U7iPhvIkdMZehWr+5GNvcA2uEEw=;
        b=QkA/Or7E6v9CkxCLP3mmxQe4fcEG/XMwzcOkGnWn0NIXgKzVlnQkxjZXMJvmhhe3j8
         swa4N5sdigAaZFBqQ/DNvFi5vGwAPfk3qiY3rjfFukn0GbL77/SE6EjmEzBFRioT0Ht/
         edSuRQK1BYKD+hXue1nAjZ8H217wMUF8N5U51Q2EK7EVZutg8mEkNsgc0Ms+7KSOy89x
         QQoiurFK4Ia1hT9Rd4zQT6Lm9J4mdddlPLdu9QPB25Sk4NemnnHjzn0qS18PZJgfLZ32
         eOvJbgvq6Z8jhxi/l0lf0GUrj67yhYXeZ8U8K311E8578J2b4s2pn/MJA6DhhOs8UlOt
         Qfrg==
X-Google-Smtp-Source: ALg8bN57R3QxrZs/9dJ2mdIq1SX/xe2DjknYtkXleFGMyRoF5ToWLyDXSZApzFfVNPsxhpLvWA7YibNCqZuMzSV4l3s=
X-Received: by 2002:a5d:8491:: with SMTP id t17mr25191421iom.11.1546242597238;
 Sun, 30 Dec 2018 23:49:57 -0800 (PST)
MIME-Version: 1.0
References: <000000000000a72593057e4c934d@google.com>
In-Reply-To: <000000000000a72593057e4c934d@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 31 Dec 2018 08:49:46 +0100
Message-ID:
 <CACT4Y+bNLT90b37QizA=W3acrWmhG0+xGv3a8Gw0N5zKTvLnzA@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in unlink_file_vma
To: syzbot <syzbot+4cbac4707f8e5215007b@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, 
	David Woodhouse <dwmw@amazon.co.uk>, Souptick Joarder <jrdr.linux@gmail.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, 
	Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181231074946.KINIYs3vDxFpw6AwkiXugowf8JHaNbL0qYmy8wlU1zY@z>

On Mon, Dec 31, 2018 at 8:44 AM syzbot
<syzbot+4cbac4707f8e5215007b@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    3d647e62686f Merge tag 's390-4.19-4' of git://git.kernel.o..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=1316f4a5400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=88e9a8a39dc0be2d
> dashboard link: https://syzkaller.appspot.com/bug?extid=4cbac4707f8e5215007b
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>
> Unfortunately, I don't have any reproducer for this crash yet.
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+4cbac4707f8e5215007b@syzkaller.appspotmail.com

Since this involves OOMs and looks like a one-off induced memory corruption:

#syz dup: kernel panic: corrupted stack end in wb_workfn

> RAX: 0000000000000002 RBX: 00000000ffffffff RCX: 000000000045df89
> RDX: 0000000000000080 RSI: 000000c420033890 RDI: 0000000000000004
> RBP: 000000c420033e90 R08: 0000000000000003 R09: 000000c420000d80
> R10: 00000000ffffffff R11: 0000000000000246 R12: 0000000000000001
> R13: 000000c42f90d718 R14: 0000000000000066 R15: 000000c42f90d708
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000068
> PGD 1d85b1067 P4D 1d85b1067 PUD 1cd360067 PMD 0
> Oops: 0002 [#1] PREEMPT SMP KASAN
> CPU: 1 PID: 2748 Comm: syz-executor0 Not tainted 4.19.0-rc7+ #55
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:__down_write arch/x86/include/asm/rwsem.h:142 [inline]
> RIP: 0010:down_write+0x97/0x130 kernel/locking/rwsem.c:72
> Code: a5 f9 31 d2 45 31 c9 41 b8 01 00 00 00 ff 75 08 48 8d 7b 60 31 c9 31
> f6 e8 c6 01 b1 f9 48 89 d8 48 ba 01 00 00 00 ff ff ff ff <f0> 48 0f c1 10
> 85 d2 74 05 e8 3b 29 fe ff 48 8d 7d a0 5a 48 89 f8
> RSP: 0000:ffff880128396ff0 EFLAGS: 00010246
> RAX: 0000000000000068 RBX: 0000000000000068 RCX: 0000000000000000
> RDX: ffffffff00000001 RSI: 0000000000000000 RDI: 0000000000000286
> RBP: ffff880128397078 R08: 0000000000000001 R09: 0000000000000000
> R10: ffff8801ce8da278 R11: 0000000000000000 R12: 1ffff10025072dff
> R13: 0000000000000068 R14: dffffc0000000000 R15: 00007fca701da000
> FS:  00007fca6ebd9700(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000068 CR3: 00000001d88cd000 CR4: 00000000001406e0
> kobject: 'syz_tun' (00000000bb2f2151): kobject_cleanup, parent
> (null)
> Call Trace:
>   i_mmap_lock_write include/linux/fs.h:482 [inline]
>   unlink_file_vma+0x75/0xb0 mm/mmap.c:166
>   free_pgtables+0x279/0x380 mm/memory.c:641
>   exit_mmap+0x2cd/0x590 mm/mmap.c:3094
>   __mmput kernel/fork.c:1001 [inline]
>   mmput+0x247/0x610 kernel/fork.c:1022
>   exit_mm kernel/exit.c:545 [inline]
>   do_exit+0xe6f/0x2610 kernel/exit.c:854
>   do_group_exit+0x177/0x440 kernel/exit.c:970
>   get_signal+0x8b0/0x1980 kernel/signal.c:2513
>   do_signal+0x9c/0x21e0 arch/x86/kernel/signal.c:816
>   exit_to_usermode_loop+0x2e5/0x380 arch/x86/entry/common.c:162
>   prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
>   syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
>   do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x457579
> Code: 24 08 48 89 01 e8 d7 2d fc ff e8 22 7a fc ff b8 02 00 00 00 48 8d 0d
> 6a 60 09 01 87 01 8b 05 62 60 09 01 83 f8 01 0f 85 8a 00 <00> 00 b8 01 00
> 00 00 88 05 9e 65 09 01 84 c0 74 72 b8 01 00 00 00
> RSP: 002b:00007fca6ebd8cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
> RAX: fffffffffffffe00 RBX: 000000000072bf08 RCX: 0000000000457579
> RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
> RBP: 000000000072bf00 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
> R13: 00007ffd2b23c63f R14: 00007fca6ebd99c0 R15: 0000000000000000
> Modules linked in:
> CR2: 0000000000000068
> ---[ end trace ea9ba926f44bc95e ]---
> RIP: 0010:__down_write arch/x86/include/asm/rwsem.h:142 [inline]
> RIP: 0010:down_write+0x97/0x130 kernel/locking/rwsem.c:72
> Code: a5 f9 31 d2 45 31 c9 41 b8 01 00 00 00 ff 75 08 48 8d 7b 60 31 c9 31
> f6 e8 c6 01 b1 f9 48 89 d8 48 ba 01 00 00 00 ff ff ff ff <f0> 48 0f c1 10
> 85 d2 74 05 e8 3b 29 fe ff 48 8d 7d a0 5a 48 89 f8
> RSP: 0000:ffff880128396ff0 EFLAGS: 00010246
> RAX: 0000000000000068 RBX: 0000000000000068 RCX: 0000000000000000
> RDX: ffffffff00000001 RSI: 0000000000000000 RDI: 0000000000000286
> RBP: ffff880128397078 R08: 0000000000000001 R09: 0000000000000000
> R10: ffff8801ce8da278 R11: 0000000000000000 R12: 1ffff10025072dff
> R13: 0000000000000068 R14: dffffc0000000000 R15: 00007fca701da000
> FS:  00007fca6ebd9700(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000068 CR3: 00000001d88cd000 CR4: 00000000001406e0
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
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/000000000000a72593057e4c934d%40google.com.
> For more options, visit https://groups.google.com/d/optout.

