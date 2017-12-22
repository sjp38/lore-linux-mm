Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3936B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 17:23:51 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id 207so11852973iti.5
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 14:23:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g127sor12489689iof.215.2017.12.22.14.23.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Dec 2017 14:23:50 -0800 (PST)
Date: Fri, 22 Dec 2017 16:23:46 -0600
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: kernel BUG at fs/userfaultfd.c:LINE!
Message-ID: <20171222222346.GB28786@zzz.localdomain>
References: <001a113a6870f5fed40560f49d0a@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001a113a6870f5fed40560f49d0a@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+83fec0ce1de1a860fbaa0774da1c839131b602a1@syzkaller.appspotmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, aarcange@redhat.com, linux-mm@kvack.org

[+Cc aarcange@redhat.com, linux-mm@kvack.org]

On Fri, Dec 22, 2017 at 01:37:01PM -0800, syzbot wrote:
> Hello,
> 
> syzkaller hit the following crash on
> 6084b576dca2e898f5c101baef151f7bfdbb606d
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
> 
> 
> ------------[ cut here ]------------
> kernel BUG at fs/userfaultfd.c:142!
> invalid opcode: 0000 [#1] SMP
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 3118 Comm: syzkaller879466 Not tainted 4.15.0-rc3-next-20171214+
> #67
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:userfaultfd_ctx_get+0x6d/0x70 fs/userfaultfd.c:142
> RSP: 0000:ffffc900012f7c30 EFLAGS: 00010293
> RAX: ffff8802134420c0 RBX: 0000000000000000 RCX: ffffffff8147a98d
> RDX: 0000000000000000 RSI: 0000000000000200 RDI: ffff880213659c40
> RBP: ffffc900012f7c48 R08: 0000000000000000 R09: 0000000000000004
> R10: ffffc900012f7cc0 R11: 0000000000000004 R12: ffff880213659c40
> R13: ffff880214ed6000 R14: 0000000000000200 R15: 0000000000000000
> FS:  00007fdf76164700(0000) GS:ffff88021fc00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020687000 CR3: 0000000211d48006 CR4: 00000000001606f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>  handle_userfault+0xd3/0xa00 fs/userfaultfd.c:445
>  do_huge_pmd_anonymous_page+0x571/0x850 mm/huge_memory.c:707
>  create_huge_pmd mm/memory.c:3838 [inline]
>  __handle_mm_fault+0xc37/0x1930 mm/memory.c:4042
>  handle_mm_fault+0x215/0x450 mm/memory.c:4108
>  __do_page_fault+0x337/0x6b0 arch/x86/mm/fault.c:1429
>  do_page_fault+0x52/0x330 arch/x86/mm/fault.c:1504
>  page_fault+0x4c/0x60 arch/x86/entry/entry_64.S:1243
> RIP: 0033:0x4453e5
> RSP: 002b:0000000020687000 EFLAGS: 00010217
> RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00000000004453d9
> RDX: 0000000020b4c000 RSI: 0000000020687000 RDI: 0000000000000600
> RBP: 0000000000000000 R08: 00000000207a4f71 R09: 00007fdf76164700
> R10: 0000000020552ffc R11: 0000000000000202 R12: 0000000000000000
> R13: 00007ffc6b2b2c2f R14: 00007fdf761649c0 R15: 0000000000000000
> Code: 5b 41 5c 41 5d 5d c3 e8 d2 f9 e3 ff 85 db 74 16 e8 c9 f9 e3 ff 8d 53
> 01 89 d8 f0 41 0f b1 55 00 89 c3 74 d7 eb e1 e8 b3 f9 e3 ff <0f> 0b 90 55 48
> 89 e5 53 48 89 fb e8 a3 f9 e3 ff 48 83 3d 73 bb
> RIP: userfaultfd_ctx_get+0x6d/0x70 fs/userfaultfd.c:142 RSP:
> ffffc900012f7c30
> ---[ end trace c25da3c687899c5a ]---
> Kernel panic - not syncing: Fatal exception
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
> 
> 

Possibly a duplicate of "KASAN: use-after-free Read in handle_userfault":

https://groups.google.com/d/msg/syzkaller-bugs/sS99S-Z-9No/O4dwVMtVAQAJ

(which *really* needs to be fixed, by the way.  Who is maintaining the
"userfaultfd" feature?)

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
