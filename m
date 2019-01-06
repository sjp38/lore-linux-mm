Return-Path: <SRS0=q3d4=PO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 353D5C43387
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 13:48:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8826206B7
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 13:48:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="svzAopue"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8826206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A67B8E0142; Sun,  6 Jan 2019 08:48:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6570F8E0001; Sun,  6 Jan 2019 08:48:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56DB48E0142; Sun,  6 Jan 2019 08:48:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF0C8E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 08:48:18 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id x12so24834152ioj.2
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 05:48:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=L3n6kchwFDpiNA0tL5XPBHgGt3dEIG0WucTmtHD6HGI=;
        b=eDyeyugf5uE+3Tx3bhXx1+0+Htcvz9knHU4N4xmIgqmKCmM1aumZHy2z7jrt1fKOzk
         FbGU7zGKjJ1NvuA1OLmBDqCShG7XGUC4GpdJ2RV84gmI38emzZ+9RPJAD+E5XaKnlVK3
         5kGF4zC93l5CBh09oSLJuYvuZtEy+XVBFpJjUUSTjLf2HtzEqrIs2ctTmD2SnhEfhj22
         qwyW2NHQpaERQMcaeoT3JJeGUjKn+02Dzcx0B4StbBPRLHmp3JAPFacrBI9bxHvdLt1p
         tDFh9ReIVC5/tkHcZDYwaIB9rfpUDEwqWoowITAQsNkP3kSooMAyZ2yG9jTGnHSKmH/S
         iEpg==
X-Gm-Message-State: AJcUukeHyw9GM2LtGJKM8HM3wyRApZ+vxXTHjdxlnFFW2NgSGxSCREKB
	G+MDOxe/YyW8OqV458gSyHpYr1RtsriNZRkGBXTVPqhRd2ouXXUzzqGpd7tpBuULvFQ1qBkqIrV
	5KXXyiAfLZgpsRCg+hfQb3uLyFldfUXloH0ROajzobHqJX3S8n8pHZrF/np8d62/5AChrplI2FA
	PjjAngNNkpQzd9PsPAPtpTp8SdomUI1C2oNXU7rcT6IQx42IQOnlTae7onpYkAD/QaxIncQ8P9X
	ChAnsY0u/Gg8rkFfm2bBZuhfawgzoaAMaCP0ZB51KnlytcmBfHI8BGYdht/JmS1W952/y2dxFdh
	T1qlD/MfnQgWzbdKHHlvfcIGiDe9N/NCoCKFtUdB787QyDUe0g1yGhAhtah54p5ZCZXiszpP3uM
	J
X-Received: by 2002:a6b:c9c8:: with SMTP id z191mr41470170iof.13.1546782497839;
        Sun, 06 Jan 2019 05:48:17 -0800 (PST)
X-Received: by 2002:a6b:c9c8:: with SMTP id z191mr41470151iof.13.1546782496898;
        Sun, 06 Jan 2019 05:48:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546782496; cv=none;
        d=google.com; s=arc-20160816;
        b=ChXWIdHiszoWCjwMfVG1V8wgmhAxCLS0v2zXCCJdrJ2vEY43xwJhvtFff2MNSVIp86
         1p/yLxCHNHQjqYYGcjd7KVIaRXSg6l89ncnBwWlpO4MtRexKEh4LQszgJLbud6+Od6go
         RFMaP2jNchkvq1JePc7F5jNLTPkvCrFDNPgzBGEOSwfzj5nV929W8OLObZaMgldqNtiL
         Pr9DL24kXPmYkHtqWXJYu/1IV1zacY//4UiV6G1iECLFWBd7/XIv79q9vMYyZbnWAKGR
         2U09YhR+OCL5Auy5PZz4kuGX3gC95a0ixFz/s453Y+ta416gwZ1Hozrt5bLDeZAeu2P3
         rA7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=L3n6kchwFDpiNA0tL5XPBHgGt3dEIG0WucTmtHD6HGI=;
        b=t1Ho5mDlwavCf09V4ABbVqVcRzDcIoK0VRa8hdIAKhuLsBKGvqUf0XnCpMRQpDSRop
         VLUwfr1x9Uv56Jb9vsPnCUUf+M9vveCNnxfoCKPKYLUgCtojGh+wuFf0tSf2A07P5THo
         frKyzThQ2gVvXII5/S7Dy7tQxZ0uWwgVmi7fsTR1Oniul/1KukhbSNLiXePMVaT/DKVi
         nVblpKcm/QTdwf3WRqIlJLR7XoaBj/kmFx/lILJ2QLW4s/5bmjNj+AKi6iyZouULJffP
         bg1lzX2uiu813KIIu73hLtwGWwmcC1E7jLRdpWpUlDPXVaC6J0adbEqoElU5v/cYWTKB
         hXmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=svzAopue;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z25sor19123405iob.90.2019.01.06.05.48.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 05:48:16 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=svzAopue;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=L3n6kchwFDpiNA0tL5XPBHgGt3dEIG0WucTmtHD6HGI=;
        b=svzAopuetC2Lbgz2CArgaGmQICderrY5AFNbXXS5oDwr4cI1bcWL2kdlvcTxq+7o57
         eel1lrDEUVZyPp8ucah4xa4M5SZcqJkTqwLA3yPLFOb7rj7SqrZSS5kMRhJjHl8elf7N
         oxAoHCx7IcovJDLFrJ3bdDaltj0LK5yr9avMzwcFJLPdT3yJeEEJ6Hj6wjrG4MyfPPm0
         9udD/+BDybr/oXUcOLXWVVFkahk2axazZAr45YfOU7p2JMulvXC+H3tuHVQ0n2qwgreF
         iDYRHmH/mgtqH0k57bGOk7PQvhC5WYD48+HJaubfHtvsHVvwmOPZ+twgF3BAeb1pOSo5
         Whaw==
X-Google-Smtp-Source: ALg8bN7BXRrbOiP+XHRKwV7+TbUPC02PXcnGKjGXlV/jDxI85/fm1p0QrfTSKPxjX2Xj2OXJpdtDeg0Eke/DZEjsZZY=
X-Received: by 2002:a5d:9456:: with SMTP id x22mr13281538ior.282.1546782496311;
 Sun, 06 Jan 2019 05:48:16 -0800 (PST)
MIME-Version: 1.0
References: <000000000000ae2357057eca1fa5@google.com>
In-Reply-To: <000000000000ae2357057eca1fa5@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 6 Jan 2019 14:48:04 +0100
Message-ID:
 <CACT4Y+Y+dph0wyKOLffXMPFPsvbviYzfn1nrJJgOL1ngkQLtVw@mail.gmail.com>
Subject: Re: KASAN: stack-out-of-bounds Read in check_stack_object
To: syzbot <syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com>
Cc: Chris von Recklinghausen <crecklin@redhat.com>, Kees Cook <keescook@chromium.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190106134804.xkRidBu0ddmPfO9yLRXFOnVh34WmeaN2nWaX3fybzPw@z>

On Sun, Jan 6, 2019 at 2:31 PM syzbot
<syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    3fed6ae4b027 ia64: fix compile without swiotlb
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=161ce1d7400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=7308e68273924137
> dashboard link: https://syzkaller.appspot.com/bug?extid=05fc3a636f5ee8830a99
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> userspace arch: i386
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10b3769f400000
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com

I suspect this is another incarnation of:
https://syzkaller.appspot.com/bug?id=4821de869e3d78a255a034bf212a4e009f6125a7
Any other ideas?

> ------------[ cut here ]------------
> DEBUG_LOCKS_WARN_ON(current->hardirq_context)
> ------------[ cut here ]------------
> Bad or missing usercopy whitelist? Kernel memory overwrite attempt detected
> to SLAB object 'task_struct' (offset 912, size 2)!
> ==================================================================
> BUG: KASAN: stack-out-of-bounds in task_stack_page
> include/linux/sched/task_stack.h:21 [inline]
> BUG: KASAN: stack-out-of-bounds in check_stack_object+0x14e/0x160
> mm/usercopy.c:39
> list_add corruption. next->prev should be prev (ffff8880ae62d8d8), but was
> 0000000000000000. (next=ffff8880a94642f0).
> Read of size 8 at addr ffff8880a9464258 by task /-1455013312
> ------------[ cut here ]------------
>
> kernel BUG at lib/list_debug.c:23!
> CPU: 0 PID: -1455013312 Comm:  Not tainted 4.20.0+ #10
> invalid opcode: 0000 [#1] PREEMPT SMP KASAN
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> CPU: 1 PID: 5941 Comm: syz-executor1 Not tainted 4.20.0+ #10
> Call Trace:
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
>
> RIP: 0010:__list_add_valid.cold+0xf/0x3c lib/list_debug.c:23
> Allocated by task 2570092928:
> Code: 34 fe eb d5 4c 89 e7 e8 2a dd 34 fe eb a3 4c 89 f7 e8 20 dd 34 fe e9
> 56 ff ff ff 4c 89 e1 48 c7 c7 60 b4 81 88 e8 f0 2d d7 fd <0f> 0b 48 89 f2
> 4c 89 e1 4c 89 ee 48 c7 c7 a0 b5 81 88 e8 d9 2d d7
> RSP: 0018:ffff8880ae707770 EFLAGS: 00010086
> RAX: 0000000000000075 RBX: ffff8880a3260730 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: ffffffff81684c16 RDI: ffffed1015ce0ee0
> RBP: ffff8880ae707788 R08: 0000000000000075 R09: ffffed1015ce5021
> R10: ffffed1015ce5020 R11: ffff8880ae728107 R12: ffff8880a94642f0
> R13: ffff8880a3260730 R14: ffff8880ae62d8d8 R15: ffff8880ae707ad0
> FS:  0000000000000000(0000) GS:ffff8880ae700000(0063) knlGS:00000000f7fbbb40
> CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
> CR2: 0000000000625208 CR3: 00000000a57b8000 CR4: 00000000001406e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>   <IRQ>
>   __list_add include/linux/list.h:60 [inline]
>   list_add include/linux/list.h:79 [inline]
>   list_move include/linux/list.h:171 [inline]
>   detach_tasks kernel/sched/fair.c:7557 [inline]
>   load_balance+0x1bdd/0x39d0 kernel/sched/fair.c:8979
>   rebalance_domains+0x815/0xf00 kernel/sched/fair.c:9366
>   run_rebalance_domains+0x376/0x4e0 kernel/sched/fair.c:9986
>   __do_softirq+0x30b/0xb11 kernel/softirq.c:292
>   invoke_softirq kernel/softirq.c:373 [inline]
>   irq_exit+0x180/0x1d0 kernel/softirq.c:413
>   exiting_irq arch/x86/include/asm/apic.h:536 [inline]
>   smp_apic_timer_interrupt+0x1b7/0x760 arch/x86/kernel/apic/apic.c:1062
>   apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
>   </IRQ>
> RIP: 0010:update_stack_state+0x24c/0x680 arch/x86/kernel/unwind_frame.c:244
> Code: 48 b9 00 00 00 00 00 fc ff df 4c 89 f6 48 c1 ee 03 80 3c 0e 00 0f 85
> b3 03 00 00 48 39 9d 30 ff ff ff 4d 8b 67 40 40 0f 97 c6 <4d> 85 e4 0f 95
> c1 40 84 ce 74 0c 39 85 44 ff ff ff 0f 84 68 01 00
> RSP: 0018:ffff88809870e768 EFLAGS: 00000283 ORIG_RAX: ffffffffffffff13
> RAX: 0000000000000001 RBX: ffff88809870ec58 RCX: dffffc0000000000
> RDX: ffff888098708000 RSI: 1ffff110130e1d00 RDI: ffff88809870e968
> RBP: ffff88809870e850 R08: 0000000000000001 R09: ffff88809870e9a8
> R10: ffff88809870e980 R11: ffff88809870e990 R12: ffff88809870e948
> R13: dffffc0000000000 R14: ffff88809870e998 R15: ffff88809870e958
>   unwind_next_frame.part.0+0x1ae/0xa90 arch/x86/kernel/unwind_frame.c:329
>   unwind_next_frame+0x3b/0x50 arch/x86/kernel/unwind_frame.c:287
>   __save_stack_trace+0x7a/0xf0 arch/x86/kernel/stacktrace.c:44
>   save_stack_trace+0x1a/0x20 arch/x86/kernel/stacktrace.c:60
>   save_stack+0x45/0xd0 mm/kasan/common.c:73
>   set_track mm/kasan/common.c:85 [inline]
>   kasan_kmalloc mm/kasan/common.c:482 [inline]
>   kasan_kmalloc+0xcf/0xe0 mm/kasan/common.c:455
>   kasan_slab_alloc+0xf/0x20 mm/kasan/common.c:397
>   slab_post_alloc_hook mm/slab.h:444 [inline]
>   slab_alloc_node mm/slab.c:3322 [inline]
>   kmem_cache_alloc_node_trace+0x13c/0x720 mm/slab.c:3648
>   __do_kmalloc_node mm/slab.c:3670 [inline]
>   __kmalloc_node_track_caller+0x3d/0x70 mm/slab.c:3685
>   __kmalloc_reserve.isra.0+0x40/0xe0 net/core/skbuff.c:140
>   __alloc_skb+0x12d/0x730 net/core/skbuff.c:208
>   alloc_skb include/linux/skbuff.h:1011 [inline]
>   alloc_skb_with_frags+0x13a/0x770 net/core/skbuff.c:5288
>   sock_alloc_send_pskb+0x8c9/0xad0 net/core/sock.c:2091
>   sock_alloc_send_skb+0x32/0x40 net/core/sock.c:2108
>   __ip6_append_data.isra.0+0x2556/0x3f20 net/ipv6/ip6_output.c:1443
>   ip6_make_skb+0x391/0x5f0 net/ipv6/ip6_output.c:1806
>   udpv6_sendmsg+0x2b58/0x3550 net/ipv6/udp.c:1460
>   inet_sendmsg+0x1af/0x740 net/ipv4/af_inet.c:798
>   sock_sendmsg_nosec net/socket.c:621 [inline]
>   sock_sendmsg+0xdd/0x130 net/socket.c:631
>   ___sys_sendmsg+0x409/0x910 net/socket.c:2116
>   __sys_sendmmsg+0x3bc/0x730 net/socket.c:2204
>   __compat_sys_sendmmsg net/compat.c:771 [inline]
>   __do_compat_sys_sendmmsg net/compat.c:778 [inline]
>   __se_compat_sys_sendmmsg net/compat.c:775 [inline]
>   __ia32_compat_sys_sendmmsg+0x9f/0x100 net/compat.c:775
>   do_syscall_32_irqs_on arch/x86/entry/common.c:326 [inline]
>   do_fast_syscall_32+0x333/0xf98 arch/x86/entry/common.c:397
>   entry_SYSENTER_compat+0x70/0x7f arch/x86/entry/entry_64_compat.S:139
> RIP: 0023:0xf7fbf869
> Code: 85 d2 74 02 89 0a 5b 5d c3 8b 04 24 c3 8b 14 24 c3 8b 3c 24 c3 90 90
> 90 90 90 90 90 90 90 90 90 90 51 52 55 89 e5 0f 34 cd 80 <5d> 5a 59 c3 90
> 90 90 90 eb 0d 90 90 90 90 90 90 90 90 90 90 90 90
> RSP: 002b:00000000f7fbb0cc EFLAGS: 00000296 ORIG_RAX: 0000000000000159
> RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000020005fc0
> RDX: 00000000000000fc RSI: 0000000008000000 RDI: 0000000000000000
> RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
> Modules linked in:
> ---[ end trace e0e50d48068f1e3d ]---
> BUG: unable to handle kernel paging request at ffffffff8cf14780
> #PF error: [normal kernel read fault]
> RIP: 0010:__list_add_valid.cold+0xf/0x3c lib/list_debug.c:23
> PGD 9874067 P4D 9874067 PUD 9875063 PMD 0
> Code: 34 fe eb d5 4c 89 e7 e8 2a dd 34 fe eb a3 4c 89 f7 e8 20 dd 34 fe e9
> 56 ff ff ff 4c 89 e1 48 c7 c7 60 b4 81 88 e8 f0 2d d7 fd <0f> 0b 48 89 f2
> 4c 89 e1 4c 89 ee 48 c7 c7 a0 b5 81 88 e8 d9 2d d7
> Thread overran stack, or stack corrupted
> RSP: 0018:ffff8880ae707770 EFLAGS: 00010086
> Oops: 0000 [#2] PREEMPT SMP KASAN
> RAX: 0000000000000075 RBX: ffff8880a3260730 RCX: 0000000000000000
> CPU: 0 PID: -1455013312 Comm:  Tainted: G      D           4.20.0+ #10
> RDX: 0000000000000000 RSI: ffffffff81684c16 RDI: ffffed1015ce0ee0
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RBP: ffff8880ae707788 R08: 0000000000000075 R09: ffffed1015ce5021
> RIP: 0010:depot_fetch_stack+0x10/0x30 lib/stackdepot.c:202
> R10: ffffed1015ce5020 R11: ffff8880ae728107 R12: ffff8880a94642f0
> Code: e6 72 22 fe e9 20 fe ff ff 48 89 df e8 d9 72 22 fe e9 f1 fd ff ff 90
> 90 90 90 89 f8 c1 ef 11 25 ff ff 1f 00 81 e7 f0 3f 00 00 <48> 03 3c c5 80
> 03 f5 8b 8b 47 0c 48 83 c7 18 c7 46 10 00 00 00 00
> R13: ffff8880a3260730 R14: ffff8880ae62d8d8 R15: ffff8880ae707ad0
> RSP: 0018:ffff8880a9463fb8 EFLAGS: 00010006
> FS:  0000000000000000(0000) GS:ffff8880ae700000(0063) knlGS:00000000f7fbbb40
> RAX: 00000000001f8880 RBX: ffff8880a9465a04 RCX: 0000000000000000
> CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
> RDX: 0000000000000000 RSI: ffff8880a9463fc0 RDI: 0000000000003ff0
> CR2: 0000000000625208 CR3: 00000000a57b8000 CR4: 00000000001406e0
> RBP: ffff8880a9463fe8 R08: 000000000000001d R09: ffffed1015cc3ef9
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> R10: ffffed1015cc3ef8 R11: ffff8880ae61f7c7 R12: ffffea0002a51900
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> R13: ffff8880a9464258 R14: ffff8880aa13d900 R15: ffff8880a9465a00
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
> syzbot can test patches for this bug, for details see:
> https://goo.gl/tpsmEJ#testing-patches
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/000000000000ae2357057eca1fa5%40google.com.
> For more options, visit https://groups.google.com/d/optout.

