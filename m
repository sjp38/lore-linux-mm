Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FEA96B0003
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 07:19:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id o19so2381210pgn.12
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 04:19:29 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id p1-v6si14820799plb.760.2018.03.08.04.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Mar 2018 04:19:27 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [bug?] Access was denied by memory protection keys in execute-only address
In-Reply-To: <CAEemH2f0LDqyR5AmUYv17OuBc5-UycckDPWgk46XU_ghQo4diw@mail.gmail.com>
References: <CAEemH2f0LDqyR5AmUYv17OuBc5-UycckDPWgk46XU_ghQo4diw@mail.gmail.com>
Date: Thu, 08 Mar 2018 23:19:12 +1100
Message-ID: <871sguep4v.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>, linuxram@us.ibm.com
Cc: Jan Stancek <jstancek@redhat.com>, ltp@lists.linux.it, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.orglinuxppc-dev@lists.ozlabs.org

Li Wang <liwang@redhat.com> writes:
> Hi,
>
> ltp/mprotect04[1] crashed by SEGV_PKUERR on ppc64(LPAR on P730, Power 8
> 8247-22L) with kernel-v4.16.0-rc4.
>
> 10000000-10020000 r-xp 00000000 fd:00 167223           mprotect04
> 10020000-10030000 r--p 00010000 fd:00 167223           mprotect04
> 10030000-10040000 rw-p 00020000 fd:00 167223           mprotect04
> 1001a380000-1001a3b0000 rw-p 00000000 00:00 0          [heap]
> 7fffa6c60000-7fffa6c80000 --xp 00000000 00:00 0 =E2=80=8B
>
> =E2=80=8B&exec_func =3D 0x10030170=E2=80=8B
>
> =E2=80=8B&func =3D 0x7fffa6c60170=E2=80=8B
>
> =E2=80=8BWhile perform =E2=80=8B
> "(*func)();" we get the
> =E2=80=8Bsegmentation fault.
> =E2=80=8B
>
> =E2=80=8Bstrace log:=E2=80=8B
>
> -------------------
> =E2=80=8Bmprotect(0x7fffaed00000, 131072, PROT_EXEC) =3D 0
> rt_sigprocmask(SIG_BLOCK, NULL, [], 8)  =3D 0
> --- SIGSEGV {si_signo=3DSIGSEGV, si_code=3DSEGV_PKUERR, si_addr=3D0x7fffa=
ed00170}
> ---=E2=80=8B

Looks like a bug to me.

Please Cc linuxppc-dev on powerpc bugs.

I also can't reproduce this failure on my machine.
Not sure what's going on?

cheers
