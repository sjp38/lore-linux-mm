Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 79E446B0269
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 21:09:36 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i12-v6so3288526pgt.13
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 18:09:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p4-v6sor2919465plk.111.2018.06.22.18.09.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 18:09:35 -0700 (PDT)
MIME-Version: 1.0
From: air icy <icytxw@gmail.com>
Date: Sat, 23 Jun 2018 09:09:34 +0800
Message-ID: <CAAzSK-wOcRRMfPiRJ91EaPgwZJ-CFj7UHrcaVuSGj2wZSEn1Og@mail.gmail.com>
Subject: UBSAN: Undefined behaviour in mm/fadvise.c
Content-Type: multipart/alternative; boundary="000000000000343994056f44cd96"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

--000000000000343994056f44cd96
Content-Type: text/plain; charset="UTF-8"

Hi,
This bug was found in Linux Kernel v4.18-rc2

 75         /* Careful about overflows. Len == 0 means "as much as possible" */
 76         endbyte = offset + len;
 77         if (!len || endbyte < len)
 78                 endbyte = -1;
 79         else
 80                 endbyte--;              /* inclusive */

$ cat report0
================================================================================
UBSAN: Undefined behaviour in mm/fadvise.c:76:10
signed integer overflow:
4 + 9223372036854775805 cannot be represented in type 'long long int'
CPU: 0 PID: 13477 Comm: syz-executor1 Not tainted 4.18.0-rc1 #2
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0x122/0x1c8 lib/dump_stack.c:113
 ubsan_epilogue+0x12/0x86 lib/ubsan.c:159
 handle_overflow+0x1c2/0x21f lib/ubsan.c:190
 __ubsan_handle_add_overflow+0x2a/0x31 lib/ubsan.c:198
 ksys_fadvise64_64+0xbf0/0xd10 mm/fadvise.c:76
 __do_sys_fadvise64 mm/fadvise.c:198 [inline]
 __se_sys_fadvise64 mm/fadvise.c:196 [inline]
 __x64_sys_fadvise64+0xa9/0x120 mm/fadvise.c:196
 do_syscall_64+0xb8/0x3a0 arch/x86/entry/common.c:290
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455a09
Code: 1d ba fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48
89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d
01 f0 ff ff 0f 83 eb b9 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007fc2de8f2c68 EFLAGS: 00000246 ORIG_RAX: 00000000000000dd
RAX: ffffffffffffffda RBX: 00007fc2de8f36d4 RCX: 0000000000455a09
RDX: 7ffffffffffffffd RSI: 0000000000000004 RDI: 0000000000000013
RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000004 R11: 0000000000000246 R12: 00000000ffffffff
R13: 000000000000007d R14: 00000000006f5c58 R15: 0000000000000000
================================================================================
This bug can be repro, if you need it, please tell me.

bugzilla url: https://bugzilla.kernel.org/show_bug.cgi?id=200209
Thanks,
Icytxw

--000000000000343994056f44cd96
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">

<pre class=3D"gmail-bz_comment_text" id=3D"gmail-comment_text_0" style=3D"f=
ont-size:medium;width:50em;font-family:monospace;white-space:pre-wrap;color=
:rgb(0,0,0);text-decoration-style:initial;text-decoration-color:initial">Hi=
,
This bug was found in Linux Kernel v4.18-rc2<br></pre><pre class=3D"gmail-b=
z_comment_text" id=3D"gmail-comment_text_0" style=3D"width:50em;text-decora=
tion-style:initial;text-decoration-color:initial"><font color=3D"#000000" s=
ize=3D"3"><span style=3D"white-space:pre-wrap"> 75         /* Careful about=
 overflows. Len =3D=3D 0 means &quot;as much as possible&quot; */
 76         endbyte =3D offset + len;
 77         if (!len || endbyte &lt; len)
 78                 endbyte =3D -1;
 79         else
 80                 endbyte--;              /* inclusive */

$ cat report0=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
UBSAN: Undefined behaviour in mm/fadvise.c:76:10
signed integer overflow:
4 + 9223372036854775805 cannot be represented in type &#39;long long int&#3=
9;
CPU: 0 PID: 13477 Comm: syz-executor1 Not tainted 4.18.0-rc1 #2
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS <a href=3D"http=
://rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org">rel-1.10.2-0-g5f4c7b1-p=
rebuilt.qemu-project.org</a> 04/01/2014
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0x122/0x1c8 lib/dump_stack.c:113
 ubsan_epilogue+0x12/0x86 lib/ubsan.c:159
 handle_overflow+0x1c2/0x21f lib/ubsan.c:190
 __ubsan_handle_add_overflow+0x2a/0x31 lib/ubsan.c:198
 ksys_fadvise64_64+0xbf0/0xd10 mm/fadvise.c:76
 __do_sys_fadvise64 mm/fadvise.c:198 [inline]
 __se_sys_fadvise64 mm/fadvise.c:196 [inline]
 __x64_sys_fadvise64+0xa9/0x120 mm/fadvise.c:196
 do_syscall_64+0xb8/0x3a0 arch/x86/entry/common.c:290
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455a09
Code: 1d ba fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 =
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 &lt;48&gt; 3d 01 f=
0 ff ff 0f 83 eb b9 fb ff c3 66 2e 0f 1f 84 00 00 00 00=20
RSP: 002b:00007fc2de8f2c68 EFLAGS: 00000246 ORIG_RAX: 00000000000000dd
RAX: ffffffffffffffda RBX: 00007fc2de8f36d4 RCX: 0000000000455a09
RDX: 7ffffffffffffffd RSI: 0000000000000004 RDI: 0000000000000013
RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000004 R11: 0000000000000246 R12: 00000000ffffffff
R13: 000000000000007d R14: 00000000006f5c58 R15: 0000000000000000
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
This bug can be repro, if you need it, please tell me.</span></font></pre><=
pre class=3D"gmail-bz_comment_text" id=3D"gmail-comment_text_0" style=3D"wi=
dth:50em;text-decoration-style:initial;text-decoration-color:initial"><font=
 color=3D"#000000" size=3D"3"><span style=3D"white-space:pre-wrap">bugzilla=
 url: <a href=3D"https://bugzilla.kernel.org/show_bug.cgi?id=3D200209">http=
s://bugzilla.kernel.org/show_bug.cgi?id=3D200209</a>
Thanks,
Icytxw</span></font></pre>

<br></div>

--000000000000343994056f44cd96--
