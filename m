Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 79D6E6B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 22:31:41 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id y2so3183019vkd.2
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 19:31:41 -0700 (PDT)
Received: from mail-ua0-x236.google.com (mail-ua0-x236.google.com. [2607:f8b0:400c:c08::236])
        by mx.google.com with ESMTPS id x131si1454vkc.121.2017.06.07.19.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 19:31:39 -0700 (PDT)
Received: by mail-ua0-x236.google.com with SMTP id x47so14008103uab.0
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 19:31:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACbyUSpTZBVa0MTvScqVmN3Mg8j0b9QDkzGZ08c7zQiH-wRy3g@mail.gmail.com>
References: <CACbyUSpTZBVa0MTvScqVmN3Mg8j0b9QDkzGZ08c7zQiH-wRy3g@mail.gmail.com>
From: Gene Blue <geneblue.mail@gmail.com>
Date: Thu, 8 Jun 2017 10:31:39 +0800
Message-ID: <CACbyUSoEZCW0oATVgk4z0z9M=KX3jxw5p+coN-xSSeCpmqGZQw@mail.gmail.com>
Subject: Fwd: kernel BUG at lib/radix-tree.c:1008!
Content-Type: multipart/alternative; boundary="001a113cec880dcdf3055169a78c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org
Cc: syzkaller <syzkaller@googlegroups.com>

--001a113cec880dcdf3055169a78c
Content-Type: text/plain; charset="UTF-8"

---------- Forwarded message ----------
From: Gene Blue <geneblue.mail@gmail.com>
Date: 2017-06-07 20:03 GMT+08:00
Subject: kernel BUG at lib/radix-tree.c:1008!
To: syzkaller@googlegroups.com


Hello:
  Another bug when fuzzing the kernel with syzkaller.

  My kernel version is  4.11.0-rc1 directly download from kernel.org.


************************************************************
*********************************
kernel BUG at lib/radix-tree.c:1008!
invalid opcode: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 1 PID: 7809 Comm: syz-executor2 Not tainted 4.11.0-rc1 #7
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88006a1bdb40 task.stack: ffff88006b348000
RIP: 0010:__radix_tree_insert+0x26b/0x2f0 lib/radix-tree.c:1008
RSP: 0018:ffff88006b34f760 EFLAGS: 00010087
RAX: ffff88006a1bdb40 RBX: 1ffff1000d669eee RCX: 0000000000000001
RDX: 0000000000000000 RSI: ffffffff81bd50fb RDI: ffffc90004032000
RBP: ffff88006b34f838 R08: 00000000000000fa R09: 0000000000010000
R10: 0000000000000003 R11: ffff8800605b8ed0 R12: 0000000000000000
R13: 1ffff1000c0b71da R14: 0000000000000000 R15: ffff8800605b8ed0
FS:  00007f8722b38700(0000) GS:ffff88003ed00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020001ff4 CR3: 000000003c6d6000 CR4: 00000000000006e0
Call Trace:
 radix_tree_insert include/linux/radix-tree.h:297 [inline]
 shmem_add_to_page_cache+0x2fe/0x420 mm/shmem.c:591
 shmem_getpage_gfp.isra.49+0x110a/0x1c90 mm/shmem.c:1792
 shmem_fault+0x21f/0x690 mm/shmem.c:1985
 __do_fault+0x83/0x210 mm/memory.c:2888
 do_read_fault mm/memory.c:3270 [inline]
 do_fault mm/memory.c:3370 [inline]
 handle_pte_fault mm/memory.c:3600 [inline]
 __handle_mm_fault+0x8d5/0x1bc0 mm/memory.c:3714
 handle_mm_fault+0x1ea/0x4c0 mm/memory.c:3751
 __do_page_fault+0x508/0xb00 arch/x86/mm/fault.c:1397
 trace_do_page_fault+0x93/0x450 arch/x86/mm/fault.c:1490
 do_async_page_fault+0x14/0x60 arch/x86/kernel/kvm.c:264
 async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:1014
RIP: 0010:do_strncpy_from_user lib/strncpy_from_user.c:44 [inline]
RIP: 0010:strncpy_from_user+0xa9/0x2b0 lib/strncpy_from_user.c:117
RSP: 0018:ffff88006b34fdc0 EFLAGS: 00010246
RAX: ffff88006a1bdb40 RBX: 0000000000000fe4 RCX: 0000000000000001
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffc90004032000
RBP: ffff88006b34fe00 R08: 0000000000000017 R09: 0000000000010000
R10: ffff88003a9568ff R11: ffffed000752ad20 R12: 0000000000000fe4
R13: 0000000020001ff4 R14: 0000000000000fe4 R15: fffffffffffffff2
 getname_flags+0x113/0x580 fs/namei.c:148
 getname+0x19/0x20 fs/namei.c:208
 do_sys_open+0x1c7/0x450 fs/open.c:1045
 SYSC_openat fs/open.c:1078 [inline]
 SyS_openat+0x30/0x40 fs/open.c:1072
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007f8722b37b58 EFLAGS: 00000292 ORIG_RAX: 0000000000000101
RAX: ffffffffffffffda RBX: 00000000007080a8 RCX: 00000000004458d9
RDX: 0000000000010100 RSI: 0000000020001ff4 RDI: ffffffffffffff9c
RBP: 0000000000000046 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000000000
R13: 0000000000000000 R14: 00007f8722b389c0 R15: 00007f8722b38700
Code: 38 ca 7c 0d 45 84 c9 74 08 4c 89 ff e8 8f a5 97 ff 4c 8b 9d 30 ff ff
ff 41 8b 03 c1 e8 1a 85 c0 0f 84 8b fe ff ff e8 15 52 78 ff <0f> 0b e8 0e
52 78 ff 49 8d 7d 03 48 b9 00 00 00 00 00 fc ff df
RIP: __radix_tree_insert+0x26b/0x2f0 lib/radix-tree.c:1008 RSP:
ffff88006b34f760
---[ end trace c1b7be537b8a3b4a ]---
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..

--001a113cec880dcdf3055169a78c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_quote">---------- Forwarded messag=
e ----------<br>From: <b class=3D"gmail_sendername">Gene Blue</b> <span dir=
=3D"ltr">&lt;<a href=3D"mailto:geneblue.mail@gmail.com">geneblue.mail@gmail=
.com</a>&gt;</span><br>Date: 2017-06-07 20:03 GMT+08:00<br>Subject: kernel =
BUG at lib/radix-tree.c:1008!<br>To: <a href=3D"mailto:syzkaller@googlegrou=
ps.com">syzkaller@googlegroups.com</a><br><br><br><div dir=3D"ltr"><div sty=
le=3D"margin:0px;padding:0px;border:0px;font-family:Arial,Helvetica,sans-se=
rif;font-size:13px">Hello:</div><div style=3D"margin:0px;padding:0px;border=
:0px;font-family:Arial,Helvetica,sans-serif;font-size:13px">=C2=A0 Another =
bug when fuzzing the kernel with syzkaller.</div><div style=3D"margin:0px;p=
adding:0px;border:0px;font-family:Arial,Helvetica,sans-serif;font-size:13px=
"><br></div><div style=3D"margin:0px;padding:0px;border:0px;font-family:Ari=
al,Helvetica,sans-serif;font-size:13px">=C2=A0 My kernel version is =C2=A04=
.11.0-rc1 directly download from=C2=A0<a href=3D"http://kernel.org/" rel=3D=
"nofollow" style=3D"margin:0px;padding:0px;border:0px;text-decoration-line:=
none;color:rgb(102,17,204)" target=3D"_blank">kernel.org</a>.</div><div><br=
></div><div><br></div><div>******************************<wbr>*************=
*****************<wbr>******************************<wbr>***</div><div><div=
>kernel BUG at lib/radix-tree.c:1008!</div><div>invalid opcode: 0000 [#1] S=
MP KASAN</div><div>Dumping ftrace buffer:</div><div>=C2=A0 =C2=A0(ftrace bu=
ffer empty)</div><div>Modules linked in:</div><div>CPU: 1 PID: 7809 Comm: s=
yz-executor2 Not tainted 4.11.0-rc1 #7</div><div>Hardware name: QEMU Standa=
rd PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011</div><div>task: ffff8800=
6a1bdb40 task.stack: ffff88006b348000</div><div>RIP: 0010:__radix_tree_inse=
rt+<wbr>0x26b/0x2f0 lib/radix-tree.c:1008</div><div>RSP: 0018:ffff88006b34f=
760 EFLAGS: 00010087</div><div>RAX: ffff88006a1bdb40 RBX: 1ffff1000d669eee =
RCX: 0000000000000001</div><div>RDX: 0000000000000000 RSI: ffffffff81bd50fb=
 RDI: ffffc90004032000</div><div>RBP: ffff88006b34f838 R08: 00000000000000f=
a R09: 0000000000010000</div><div>R10: 0000000000000003 R11: ffff8800605b8e=
d0 R12: 0000000000000000</div><div>R13: 1ffff1000c0b71da R14: 0000000000000=
000 R15: ffff8800605b8ed0</div><div>FS: =C2=A000007f8722b38700(0000) GS:fff=
f88003ed00000(0000) knlGS:0000000000000000</div><div>CS: =C2=A00010 DS: 000=
0 ES: 0000 CR0: 0000000080050033</div><div>CR2: 0000000020001ff4 CR3: 00000=
0003c6d6000 CR4: 00000000000006e0</div><div>Call Trace:</div><div>=C2=A0rad=
ix_tree_insert include/linux/radix-tree.h:297 [inline]</div><div>=C2=A0shme=
m_add_to_page_cache+<wbr>0x2fe/0x420 mm/shmem.c:591</div><div>=C2=A0shmem_g=
etpage_gfp.isra.49+<wbr>0x110a/0x1c90 mm/shmem.c:1792</div><div>=C2=A0shmem=
_fault+0x21f/0x690 mm/shmem.c:1985</div><div>=C2=A0__do_fault+0x83/0x210 mm=
/memory.c:2888</div><div>=C2=A0do_read_fault mm/memory.c:3270 [inline]</div=
><div>=C2=A0do_fault mm/memory.c:3370 [inline]</div><div>=C2=A0handle_pte_f=
ault mm/memory.c:3600 [inline]</div><div>=C2=A0__handle_mm_fault+0x8d5/<wbr=
>0x1bc0 mm/memory.c:3714</div><div>=C2=A0handle_mm_fault+0x1ea/0x4c0 mm/mem=
ory.c:3751</div><div>=C2=A0__do_page_fault+0x508/0xb00 arch/x86/mm/fault.c:=
1397</div><div>=C2=A0trace_do_page_fault+0x93/<wbr>0x450 arch/x86/mm/fault.=
c:1490</div><div>=C2=A0do_async_page_fault+0x14/0x60 arch/x86/kernel/kvm.c:=
264</div><div>=C2=A0async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:10=
14</div><div>RIP: 0010:do_strncpy_from_user lib/strncpy_from_user.c:44 [inl=
ine]</div><div>RIP: 0010:strncpy_from_user+0xa9/<wbr>0x2b0 lib/strncpy_from=
_user.c:117</div><div>RSP: 0018:ffff88006b34fdc0 EFLAGS: 00010246</div><div=
>RAX: ffff88006a1bdb40 RBX: 0000000000000fe4 RCX: 0000000000000001</div><di=
v>RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffc90004032000</div><d=
iv>RBP: ffff88006b34fe00 R08: 0000000000000017 R09: 0000000000010000</div><=
div>R10: ffff88003a9568ff R11: ffffed000752ad20 R12: 0000000000000fe4</div>=
<div>R13: 0000000020001ff4 R14: 0000000000000fe4 R15: fffffffffffffff2</div=
><div>=C2=A0getname_flags+0x113/0x580 fs/namei.c:148</div><div>=C2=A0getnam=
e+0x19/0x20 fs/namei.c:208</div><div>=C2=A0do_sys_open+0x1c7/0x450 fs/open.=
c:1045</div><div>=C2=A0SYSC_openat fs/open.c:1078 [inline]</div><div>=C2=A0=
SyS_openat+0x30/0x40 fs/open.c:1072</div><div>=C2=A0entry_SYSCALL_64_fastpa=
th+<wbr>0x1f/0xc2</div><div>RIP: 0033:0x4458d9</div><div>RSP: 002b:00007f87=
22b37b58 EFLAGS: 00000292 ORIG_RAX: 0000000000000101</div><div>RAX: fffffff=
fffffffda RBX: 00000000007080a8 RCX: 00000000004458d9</div><div>RDX: 000000=
0000010100 RSI: 0000000020001ff4 RDI: ffffffffffffff9c</div><div>RBP: 00000=
00000000046 R08: 0000000000000000 R09: 0000000000000000</div><div>R10: 0000=
000000000000 R11: 0000000000000292 R12: 0000000000000000</div><div>R13: 000=
0000000000000 R14: 00007f8722b389c0 R15: 00007f8722b38700</div><div>Code: 3=
8 ca 7c 0d 45 84 c9 74 08 4c 89 ff e8 8f a5 97 ff 4c 8b 9d 30 ff ff ff 41 8=
b 03 c1 e8 1a 85 c0 0f 84 8b fe ff ff e8 15 52 78 ff &lt;0f&gt; 0b e8 0e 52=
 78 ff 49 8d 7d 03 48 b9 00 00 00 00 00 fc ff df=C2=A0</div><div>RIP: __rad=
ix_tree_insert+0x26b/<wbr>0x2f0 lib/radix-tree.c:1008 RSP: ffff88006b34f760=
</div><div>---[ end trace c1b7be537b8a3b4a ]---</div><div>Kernel panic - no=
t syncing: Fatal exception</div><div>Dumping ftrace buffer:</div><div>=C2=
=A0 =C2=A0(ftrace buffer empty)</div><div>Kernel Offset: disabled</div><div=
>Rebooting in 86400 seconds..</div></div></div>
</div><br></div>

--001a113cec880dcdf3055169a78c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
