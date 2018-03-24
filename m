Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 429DB6B0012
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 09:55:53 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w10so7523504wrg.15
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 06:55:53 -0700 (PDT)
Received: from huawei.com ([45.249.212.255])
        by mx.google.com with ESMTPS id 62si8342402wrg.347.2018.03.24.06.55.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Mar 2018 06:55:51 -0700 (PDT)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 7/7] Enable KASan for arm
Date: Sat, 24 Mar 2018 13:55:37 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C007750D@dggemm510-mbs.china.huawei.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "linux@rasmusvillemoes.dk" <linux@rasmusvillemoes.dk>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "tixy@linaro.org" <tixy@linaro.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "james.morse@arm.com" <james.morse@arm.com>, "zhichao.huang@linaro.org" <zhichao.huang@linaro.org>, "jinb.park7@gmail.com" <jinb.park7@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "philip@cog.systems" <philip@cog.systems>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/20/2018 2:30 AM, kbuild test robot wrote:
>All errors (new ones prefixed by >>):
>
>   arch/arm/kernel/entry-common.S: Assembler messages:
>>> arch/arm/kernel/entry-common.S:85: Error: invalid constant (ffffffffb6e=
00000) after fixup

I'm sorry!
We need to add the fellowing code to solve the upper error:
> git diff
diff --git a/arch/arm/kernel/entry-common.S b/arch/arm/kernel/entry-common.=
S
index b7d0c6c..9b728c5 100644
--- a/arch/arm/kernel/entry-common.S
+++ b/arch/arm/kernel/entry-common.S
@@ -82,7 +82,8 @@ ret_fast_syscall:
        str     r0, [sp, #S_R0 + S_OFF]!        @ save returned r0
        disable_irq_notrace                     @ disable interrupts
        ldr     r2, [tsk, #TI_ADDR_LIMIT]
-	cmp     r2, #TASK_SIZE
+	ldr		r1, =3DTASK_SIZE
+	cmp		r2, r1
        blne    addr_limit_check_failed
        ldr     r1, [tsk, #TI_FLAGS]            @ re-check for syscall trac=
ing
        tst     r1, #_TIF_SYSCALL_WORK | _TIF_WORK_MASK
