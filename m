Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB6C66B026B
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 03:36:42 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id z3so7001366plh.18
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 00:36:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e11sor3553296pgu.150.2017.12.19.00.36.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 00:36:41 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 19 Dec 2017 09:36:20 +0100
Message-ID: <CACT4Y+a0NvG-qpufVcvObd_hWKF9xmTjmjCvV3_13LSgcFXL+Q@mail.gmail.com>
Subject: mmots build error: version control conflict marker in file
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

Hello,

syzbot hit the following crash on 80f3359313dfd0e574d0d245dd93a7c3bf39e1fa
git://git.cmpxchg.org/linux-mmots.git master

failed to run /usr/bin/make [make bzImage -j 32
CC=3D/syzkaller/gcc/bin/gcc]: exit status 2
scripts/kconfig/conf  --silentoldconfig Kconfig
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  UPD     include/config/kernel.release
  CHK     scripts/mod/devicetable-offsets.h
  CHK     include/generated/utsrelease.h
  UPD     include/generated/utsrelease.h
  CHK     include/generated/bounds.h
  CHK     include/generated/timeconst.h
  CC      arch/x86/kernel/asm-offsets.s
In file included from ./arch/x86/include/asm/cpufeature.h:5:0,
                 from ./arch/x86/include/asm/thread_info.h:53,
                 from ./include/linux/thread_info.h:38,
                 from ./arch/x86/include/asm/preempt.h:7,
                 from ./include/linux/preempt.h:81,
                 from ./include/linux/spinlock.h:51,
                 from ./include/linux/mmzone.h:8,
                 from ./include/linux/gfp.h:6,
                 from ./include/linux/slab.h:15,
                 from ./include/linux/crypto.h:24,
                 from arch/x86/kernel/asm-offsets.c:9:
./arch/x86/include/asm/processor.h:340:1: error: version control
conflict marker in file
 <<<<<<< HEAD
 ^~~~~~~
./arch/x86/include/asm/processor.h:346:24: error: field =E2=80=98stack=E2=
=80=99 has
incomplete type
  struct SYSENTER_stack stack;
                        ^~~~~
./arch/x86/include/asm/processor.h:347:1: error: version control
conflict marker in file
 =3D=3D=3D=3D=3D=3D=3D
 ^~~~~~~
Kbuild:56: recipe for target 'arch/x86/kernel/asm-offsets.s' failed
make[1]: *** [arch/x86/kernel/asm-offsets.s] Error 1
Makefile:1090: recipe for target 'prepare0' failed
make: *** [prepare0] Error 2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
