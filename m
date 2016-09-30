Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD366B0253
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 05:10:29 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so18302131wmg.3
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:10:29 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id le9si19630550wjb.117.2016.09.30.02.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Sep 2016 02:10:28 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id b80so31316773wme.0
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:10:28 -0700 (PDT)
MIME-Version: 1.0
References: <57ed9c80.HCJe/31KIVzJsQS4%xiaolong.ye@intel.com>
In-Reply-To: <57ed9c80.HCJe/31KIVzJsQS4%xiaolong.ye@intel.com>
From: Janis Danisevskis <jdanis@google.com>
Date: Fri, 30 Sep 2016 09:10:16 +0000
Message-ID: <CAAdwW5Owhr07LrxmoBWuCLVW7hVZxPvXOKVGb+ipKOFhQh3_+A@mail.gmail.com>
Subject: Re: [mm] 3f40a9185a: kernel BUG at kernel/cred.c:768!
Content-Type: multipart/alternative; boundary=047d7beb9b761b312b053db5f74f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <xiaolong.ye@intel.com>, Jann Horn <jann@thejh.net>
Cc: lkp@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, Nick Kralevich <nnk@google.com>, "Serge E. Hallyn" <serge@hallyn.com>, James Morris <james.l.morris@oracle.com>, Eric Paris <eparis@parisplace.org>, Stephen Smalley <sds@tycho.nsa.gov>, Paul Moore <paul@paul-moore.com>, Alexander Viro <viro@zeniv.linux.org.uk>, security@kernel.org

--047d7beb9b761b312b053db5f74f
Content-Type: text/plain; charset=UTF-8

Jann: I guess a environ_(mem_)release is needed because private_data of mem
and environ are now different.

On Thu, Sep 29, 2016 at 11:58 PM kernel test robot <xiaolong.ye@intel.com>
wrote:

> FYI, we noticed the following commit:
>
> https://github.com/0day-ci/linux
> Jann-Horn/fs-exec-don-t-force-writing-memory-access/20160929-222244
> commit 3f40a9185af5f5335b8117178c706b74537b960b ("mm: add LSM hook for
> writes to readonly memory")
>
> in testcase: boot
>
> on test machine: qemu-system-i386 -enable-kvm -cpu Haswell,+smep,+smap -m
> 360M
>
> caused below changes:
>
>
> +------------------------------------------+------------+------------+
> |                                          | dc00268ef0 | 3f40a9185a |
> +------------------------------------------+------------+------------+
> | boot_successes                           | 24         | 2          |
> | boot_failures                            | 0          | 18         |
> | kernel_BUG_at_kernel/cred.c              | 0          | 12         |
> | invalid_opcode:#[##]SMP                  | 0          | 12         |
> | EIP_is_at__invalid_creds                 | 0          | 12         |
> | calltrace:SyS_exit_group                 | 0          | 18         |
> | Kernel_panic-not_syncing:Fatal_exception | 0          | 18         |
> | BUG:unable_to_handle_kernel              | 0          | 10         |
> | Oops                                     | 0          | 10         |
> | EIP_is_at_mem_release                    | 0          | 10         |
> +------------------------------------------+------------+------------+
>
>
>
> [   23.725743] trinity-c0 (12124) used greatest stack depth: 6144 bytes
> left
> [   23.729863] CRED: ->security {83184389, d88918c4}
> [   23.730466] ------------[ cut here ]------------
> [   23.731054] kernel BUG at kernel/cred.c:768!
> [   23.731770] invalid opcode: 0000 [#1] SMP
> [   23.732270] Modules linked in:
> [   23.732674] CPU: 0 PID: 10617 Comm: trinity-main Not tainted
> 4.8.0-rc8-00015-g3f40a91 #78
> [   23.733678] task: 8c79a6c0 task.stack: 8c48c000
> [   23.734248] EIP: 0060:[<8104cad8>] EFLAGS: 00010292 CPU: 0
> [   23.734962] EIP is at __invalid_creds+0x35/0x37
> [   23.735523] EAX: 00000025 EBX: 8d11a458 ECX: 8106ce3c EDX: 00000001
> [   23.736304] ESI: 813d667c EDI: 0000010f EBP: 8c48ded4 ESP: 8c48deb8
> [   23.737080]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> [   23.737750] CR0: 80050033 CR2: 7fc1ed30 CR3: 01647000 CR4: 00040690
> [   23.738529] DR0: c0100220 DR1: 00000000 DR2: 00000000 DR3: 00000000
> [   23.739308] DR6: ffff0ff0 DR7: 00050602
> [   23.739793] Stack:
> [   23.740054]  813d6660 813d667c 0000010f 813d6643 8d11a458 8d03ab80
> 8847b8e4 8c48dee4
> [   23.741161]  811153aa 8ca8f6c0 00000010 8c48df08 810de5a9 8ca8f6c8
> 88460a18 8847b8e4
> [   23.742265]  93c83c50 8ca8f6c0 8c79a6c0 8ca8e700 8c48df10 810de65c
> 8c48df28 8104a7a7
> [   23.743369] Call Trace:
> [   23.743700]  [<811153aa>] mem_release+0x35/0x4e
> [   23.744284]  [<810de5a9>] __fput+0xd8/0x162
> [   23.744815]  [<810de65c>] ____fput+0x8/0xa
> [   23.745333]  [<8104a7a7>] task_work_run+0x54/0x78
> [   23.745935]  [<8103a20a>] do_exit+0x33c/0x7ec
> [   23.746478]  [<810dd644>] ? vfs_write+0x9a/0xa4
> [   23.747051]  [<8103a711>] do_group_exit+0x30/0x86
> [   23.747634]  [<8103a778>] SyS_exit_group+0x11/0x11
> [   23.748236]  [<81000e0b>] do_int80_syscall_32+0x43/0x55
> [   23.748909]  [<812b8911>] entry_INT80_32+0x31/0x31
> [   23.749503] Code: 89 cf 68 43 66 3d 81 e8 1e 9a 05 00 57 56 68 60 66 3d
> 81 e8 12 9a 05 00 64 8b 0d dc 8a 4f 81 ba 72 66 3d 81 89 d8 e8 ac fe ff ff
> <0f> 0b 81 78 0c 64 65 73 43 74 08 55 89 e5 e8 b8 ff ff ff c3 55
> [   23.753032] EIP: [<8104cad8>] __invalid_creds+0x35/0x37 SS:ESP
> 0068:8c48deb8
> [   23.753971] ---[ end trace e46a82be55c05913 ]---
> [   23.754894] BUG: unable to handle kernel NULL pointer dereference at
>  (null)
>
>
>
>
>
> Thanks,
> Kernel Test Robot
>

--047d7beb9b761b312b053db5f74f
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Jann: I guess a environ_(mem_)release is needed because pr=
ivate_data of mem and environ are now different.</div><br><div class=3D"gma=
il_quote"><div dir=3D"ltr">On Thu, Sep 29, 2016 at 11:58 PM kernel test rob=
ot &lt;<a href=3D"mailto:xiaolong.ye@intel.com">xiaolong.ye@intel.com</a>&g=
t; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 =
.8ex;border-left:1px #ccc solid;padding-left:1ex">FYI, we noticed the follo=
wing commit:<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
<a href=3D"https://github.com/0day-ci/linux" rel=3D"noreferrer" class=3D"gm=
ail_msg" target=3D"_blank">https://github.com/0day-ci/linux</a> Jann-Horn/f=
s-exec-don-t-force-writing-memory-access/20160929-222244<br class=3D"gmail_=
msg">
commit 3f40a9185af5f5335b8117178c706b74537b960b (&quot;mm: add LSM hook for=
 writes to readonly memory&quot;)<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
in testcase: boot<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
on test machine: qemu-system-i386 -enable-kvm -cpu Haswell,+smep,+smap -m 3=
60M<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
caused below changes:<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
+------------------------------------------+------------+------------+<br c=
lass=3D"gmail_msg">
|=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=
 dc00268ef0 | 3f40a9185a |<br class=3D"gmail_msg">
+------------------------------------------+------------+------------+<br c=
lass=3D"gmail_msg">
| boot_successes=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 24=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| 2=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |<br class=3D"gmail_msg">
| boot_failures=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 | 18=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br class=3D"gmail_msg">
| kernel_BUG_at_kernel/cred.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 | 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 12=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0|<br class=3D"gmail_msg">
| invalid_opcode:#[##]SMP=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 | 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 12=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0|<br class=3D"gmail_msg">
| EIP_is_at__invalid_creds=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 12=C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0|<br class=3D"gmail_msg">
| calltrace:SyS_exit_group=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 18=C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0|<br class=3D"gmail_msg">
| Kernel_panic-not_syncing:Fatal_exception | 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 | 18=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br class=3D"gmail_msg">
| BUG:unable_to_handle_kernel=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 | 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 10=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0|<br class=3D"gmail_msg">
| Oops=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 0=C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 | 10=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|<br clas=
s=3D"gmail_msg">
| EIP_is_at_mem_release=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | 0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 10=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0|<br class=3D"gmail_msg">
+------------------------------------------+------------+------------+<br c=
lass=3D"gmail_msg">
<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.725743] trinity-c0 (12124) used greatest stack depth: 6144=
 bytes left<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.729863] CRED: -&gt;security {83184389, d88918c4}<br class=
=3D"gmail_msg">
[=C2=A0 =C2=A023.730466] ------------[ cut here ]------------<br class=3D"g=
mail_msg">
[=C2=A0 =C2=A023.731054] kernel BUG at kernel/cred.c:768!<br class=3D"gmail=
_msg">
[=C2=A0 =C2=A023.731770] invalid opcode: 0000 [#1] SMP<br class=3D"gmail_ms=
g">
[=C2=A0 =C2=A023.732270] Modules linked in:<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.732674] CPU: 0 PID: 10617 Comm: trinity-main Not tainted 4=
.8.0-rc8-00015-g3f40a91 #78<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.733678] task: 8c79a6c0 task.stack: 8c48c000<br class=3D"gm=
ail_msg">
[=C2=A0 =C2=A023.734248] EIP: 0060:[&lt;8104cad8&gt;] EFLAGS: 00010292 CPU:=
 0<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.734962] EIP is at __invalid_creds+0x35/0x37<br class=3D"gm=
ail_msg">
[=C2=A0 =C2=A023.735523] EAX: 00000025 EBX: 8d11a458 ECX: 8106ce3c EDX: 000=
00001<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.736304] ESI: 813d667c EDI: 0000010f EBP: 8c48ded4 ESP: 8c4=
8deb8<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.737080]=C2=A0 DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068=
<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.737750] CR0: 80050033 CR2: 7fc1ed30 CR3: 01647000 CR4: 000=
40690<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.738529] DR0: c0100220 DR1: 00000000 DR2: 00000000 DR3: 000=
00000<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.739308] DR6: ffff0ff0 DR7: 00050602<br class=3D"gmail_msg"=
>
[=C2=A0 =C2=A023.739793] Stack:<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.740054]=C2=A0 813d6660 813d667c 0000010f 813d6643 8d11a458=
 8d03ab80 8847b8e4 8c48dee4<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.741161]=C2=A0 811153aa 8ca8f6c0 00000010 8c48df08 810de5a9=
 8ca8f6c8 88460a18 8847b8e4<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.742265]=C2=A0 93c83c50 8ca8f6c0 8c79a6c0 8ca8e700 8c48df10=
 810de65c 8c48df28 8104a7a7<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.743369] Call Trace:<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.743700]=C2=A0 [&lt;811153aa&gt;] mem_release+0x35/0x4e<br =
class=3D"gmail_msg">
[=C2=A0 =C2=A023.744284]=C2=A0 [&lt;810de5a9&gt;] __fput+0xd8/0x162<br clas=
s=3D"gmail_msg">
[=C2=A0 =C2=A023.744815]=C2=A0 [&lt;810de65c&gt;] ____fput+0x8/0xa<br class=
=3D"gmail_msg">
[=C2=A0 =C2=A023.745333]=C2=A0 [&lt;8104a7a7&gt;] task_work_run+0x54/0x78<b=
r class=3D"gmail_msg">
[=C2=A0 =C2=A023.745935]=C2=A0 [&lt;8103a20a&gt;] do_exit+0x33c/0x7ec<br cl=
ass=3D"gmail_msg">
[=C2=A0 =C2=A023.746478]=C2=A0 [&lt;810dd644&gt;] ? vfs_write+0x9a/0xa4<br =
class=3D"gmail_msg">
[=C2=A0 =C2=A023.747051]=C2=A0 [&lt;8103a711&gt;] do_group_exit+0x30/0x86<b=
r class=3D"gmail_msg">
[=C2=A0 =C2=A023.747634]=C2=A0 [&lt;8103a778&gt;] SyS_exit_group+0x11/0x11<=
br class=3D"gmail_msg">
[=C2=A0 =C2=A023.748236]=C2=A0 [&lt;81000e0b&gt;] do_int80_syscall_32+0x43/=
0x55<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.748909]=C2=A0 [&lt;812b8911&gt;] entry_INT80_32+0x31/0x31<=
br class=3D"gmail_msg">
[=C2=A0 =C2=A023.749503] Code: 89 cf 68 43 66 3d 81 e8 1e 9a 05 00 57 56 68=
 60 66 3d 81 e8 12 9a 05 00 64 8b 0d dc 8a 4f 81 ba 72 66 3d 81 89 d8 e8 ac=
 fe ff ff &lt;0f&gt; 0b 81 78 0c 64 65 73 43 74 08 55 89 e5 e8 b8 ff ff ff =
c3 55<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.753032] EIP: [&lt;8104cad8&gt;] __invalid_creds+0x35/0x37 =
SS:ESP 0068:8c48deb8<br class=3D"gmail_msg">
[=C2=A0 =C2=A023.753971] ---[ end trace e46a82be55c05913 ]---<br class=3D"g=
mail_msg">
[=C2=A0 =C2=A023.754894] BUG: unable to handle kernel NULL pointer derefere=
nce at=C2=A0 =C2=A0(null)<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
Thanks,<br class=3D"gmail_msg">
Kernel Test Robot<br class=3D"gmail_msg">
</blockquote></div>

--047d7beb9b761b312b053db5f74f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
