Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 81DC96B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 19:25:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d64-v6so9310173pfd.13
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 16:25:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x2-v6si16171660plr.223.2018.06.18.16.25.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 16:25:47 -0700 (PDT)
Date: Mon, 18 Jun 2018 16:25:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 200095] New: kasan: GPF could be caused by NULL-ptr deref
 or user memory access
Message-Id: <20180618162545.521b8da29637cf7ec7608fa6@linux-foundation.org>
In-Reply-To: <bug-200095-27@https.bugzilla.kernel.org/>
References: <bug-200095-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, icytxw@gmail.com, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

Could the KASAN people please help interpret this one?

On Sun, 17 Jun 2018 03:10:59 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=200095
> 
>             Bug ID: 200095
>            Summary: kasan: GPF could be caused by NULL-ptr deref or user
>                     memory access
>            Product: Alternate Trees
>            Version: 2.5
>     Kernel Version: v4.17
>           Hardware: All
>                 OS: Linux
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: mm
>           Assignee: akpm@linux-foundation.org
>           Reporter: icytxw@gmail.com
>         Regression: No
> 
> Created attachment 276605
>   --> https://bugzilla.kernel.org/attachment.cgi?id=276605&action=edit
> log0
> 
> $ cat ../949034f0ecf05fba42df7e5f51a55453eba53e06/report0 
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN PTI
> CPU: 0 PID: 7388 Comm: syz-executor1 Not tainted 4.17.0 #1
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
> RIP: 0010:__insert_vmap_area+0x8c/0x3c0 mm/vmalloc.c:373
> Code: 76 e8 78 3f e5 ff 4c 89 e0 48 c1 e8 03 80 3c 28 00 0f 85 c7 02 00 00 4c
> 8d 6b e8 4d 8b 3c 24 49 8d 7d 08 48 89 fa 48 c1 ea 03 <80> 3c 2a 00 0f 85 a0 02
> 00 00 4c 3b 7b f0 72 9d e8 3f 3f e5 ff 41 
> RSP: 0018:ffff8800550778c0 EFLAGS: 00010207
> RAX: 1ffff1000d80fd40 RBX: 0000041600000406 RCX: ffffffff8324e1de
> RDX: 00000082c000007e RSI: ffffffff814d6dd8 RDI: 00000416000003f6
> RBP: dffffc0000000000 R08: 1ffffffff08cf184 R09: fffffbfff08cf184
> R10: 0000000000000001 R11: fffffbfff08cf184 R12: ffff88006c07ea00
> R13: 00000416000003ee R14: ffffed000d80fd41 R15: ffffc90000712000
> FS:  0000000002619940(0000) GS:ffff88006d400000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000002622978 CR3: 0000000055078000 CR4: 00000000000006f0
> DR0: 0000000020000ac0 DR1: 0000000020000ac0 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> Call Trace:
> Modules linked in:
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> ---[ end trace 650893cd43a30701 ]---
> RIP: 0010:__insert_vmap_area+0x8c/0x3c0 mm/vmalloc.c:373
> Code: 76 e8 78 3f e5 ff 4c 89 e0 48 c1 e8 03 80 3c 28 00 0f 85 c7 02 00 00 4c
> 8d 6b e8 4d 8b 3c 24 49 8d 7d 08 48 89 fa 48 c1 ea 03 <80> 3c 2a 00 0f 85 a0 02
> 00 00 4c 3b 7b f0 72 9d e8 3f 3f e5 ff 41 
> RSP: 0018:ffff8800550778c0 EFLAGS: 00010207
> RAX: 1ffff1000d80fd40 RBX: 0000041600000406 RCX: ffffffff8324e1de
> RDX: 00000082c000007e RSI: ffffffff814d6dd8 RDI: 00000416000003f6
> RBP: dffffc0000000000 R08: 1ffffffff08cf184 R09: fffffbfff08cf184
> R10: 0000000000000001 R11: fffffbfff08cf184 R12: ffff88006c07ea00
> R13: 00000416000003ee R14: ffffed000d80fd41 R15: ffffc90000712000
> FS:  0000000002619940(0000) GS:ffff88006d400000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000002622978 CR3: 0000000055078000 CR4: 00000000000006f0
> DR0: 0000000020000ac0 DR1: 0000000020000ac0 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.
