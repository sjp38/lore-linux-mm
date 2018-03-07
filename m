Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0710A6B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 03:09:09 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id y43so954165uac.16
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 00:09:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l128sor7493680vkb.127.2018.03.07.00.09.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Mar 2018 00:09:07 -0800 (PST)
MIME-Version: 1.0
From: Li Wang <liwang@redhat.com>
Date: Wed, 7 Mar 2018 16:09:06 +0800
Message-ID: <CAEemH2f0LDqyR5AmUYv17OuBc5-UycckDPWgk46XU_ghQo4diw@mail.gmail.com>
Subject: [bug?] Access was denied by memory protection keys in execute-only address
Content-Type: multipart/alternative; boundary="001a114268ecc061540566ce12b4"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com, mpe@ellerman.id.au
Cc: Jan Stancek <jstancek@redhat.com>, ltp@lists.linux.it, linux-mm@kvack.org

--001a114268ecc061540566ce12b4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi,

ltp/mprotect04[1] crashed by SEGV_PKUERR on ppc64(LPAR on P730, Power 8
8247-22L) with kernel-v4.16.0-rc4.

10000000-10020000 r-xp 00000000 fd:00 167223           mprotect04
10020000-10030000 r--p 00010000 fd:00 167223           mprotect04
10030000-10040000 rw-p 00020000 fd:00 167223           mprotect04
1001a380000-1001a3b0000 rw-p 00000000 00:00 0          [heap]
7fffa6c60000-7fffa6c80000 --xp 00000000 00:00 0 =E2=80=8B

=E2=80=8B&exec_func =3D 0x10030170=E2=80=8B

=E2=80=8B&func =3D 0x7fffa6c60170=E2=80=8B

=E2=80=8BWhile perform =E2=80=8B
"(*func)();" we get the
=E2=80=8Bsegmentation fault.
=E2=80=8B

=E2=80=8Bstrace log:=E2=80=8B

-------------------
=E2=80=8Bmprotect(0x7fffaed00000, 131072, PROT_EXEC) =3D 0
rt_sigprocmask(SIG_BLOCK, NULL, [], 8)  =3D 0
--- SIGSEGV {si_signo=3DSIGSEGV, si_code=3DSEGV_PKUERR, si_addr=3D0x7fffaed=
00170}
---=E2=80=8B



[1]
https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/sysc=
alls/mprotect/mprotect04.c
=E2=80=8B

--=20
Li Wang
liwang@redhat.com

--001a114268ecc061540566ce12b4
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div style=3D"font-family:monospace,monospace" class=3D"gm=
ail_default">Hi,<br><br>ltp/mprotect04[1] crashed by SEGV_PKUERR on ppc64(L=
PAR on P730, Power 8 8247-22L) with kernel-v4.16.0-rc4.<br></div><div class=
=3D"gmail_default"><span style=3D"font-family:monospace,monospace"><br>1000=
0000-10020000 r-xp 00000000 fd:00 167223=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 mprotect04<br>10020000-10030000 r--p 00010000 f=
d:00 167223=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mpr=
otect04<br>10030000-10040000 rw-p 00020000 fd:00 167223=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mprotect04<br>1001a380000-1001a3=
b0000 rw-p 00000000 00:00 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 [heap]<br>7fffa6c60000-7fffa6c80000 --xp 00000000 00:00 0 =E2=80=8B<=
/span></div><span style=3D"font-family:monospace,monospace"><br><div style=
=3D"font-family:monospace,monospace;display:inline" class=3D"gmail_default"=
>=E2=80=8B&amp;exec_func =3D 0x10030170=E2=80=8B</div><br></span><div class=
=3D"gmail_default"><span style=3D"font-family:monospace,monospace">=E2=80=
=8B&amp;func =3D 0x7fffa6c60170=E2=80=8B<br><br></span></div><span style=3D=
"font-family:arial,helvetica,sans-serif"><div style=3D"display:inline" clas=
s=3D"gmail_default"><span style=3D"font-family:monospace,monospace">=E2=80=
=8BWhile perform =E2=80=8B</span></div><span style=3D"font-family:monospace=
,monospace">&quot;(*func)();&quot; we get the </span><div style=3D"font-fam=
ily:monospace,monospace;display:inline" class=3D"gmail_default">=E2=80=8Bse=
gmentation fault.<br>=E2=80=8B</div><br><div style=3D"font-family:monospace=
,monospace;display:inline" class=3D"gmail_default">=E2=80=8Bstrace log:=E2=
=80=8B</div><br>-------------------<br></span><div class=3D"gmail_default" =
style=3D"font-family:monospace,monospace;display:inline">=E2=80=8Bmprotect(=
0x7fffaed00000, 131072, PROT_EXEC) =3D 0<br>rt_sigprocmask(SIG_BLOCK, NULL,=
 [], 8) =C2=A0=3D 0<br>--- SIGSEGV {si_signo=3DSIGSEGV, si_code=3DSEGV_PKUE=
RR, si_addr=3D0x7fffaed00170} ---=E2=80=8B</div><br><br><br><span style=3D"=
font-family:monospace,monospace">[1] <a href=3D"https://github.com/linux-te=
st-project/ltp/blob/master/testcases/kernel/syscalls/mprotect/mprotect04.c"=
>https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/sys=
calls/mprotect/mprotect04.c</a>=E2=80=8B</span><br><br>-- <br><div class=3D=
"gmail_signature">Li Wang<br><a target=3D"_blank" href=3D"mailto:liwang@red=
hat.com">liwang@redhat.com</a></div>
</div>

--001a114268ecc061540566ce12b4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
