Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFB696B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 04:27:54 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id 123so9653587vkm.4
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:27:54 -0700 (PDT)
Received: from mail-vk0-x22d.google.com (mail-vk0-x22d.google.com. [2607:f8b0:400c:c05::22d])
        by mx.google.com with ESMTPS id t9si1478050uab.1.2017.03.16.01.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 01:27:54 -0700 (PDT)
Received: by mail-vk0-x22d.google.com with SMTP id d188so20065248vka.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:27:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170316044704.GA729@jagdpanzerIV.localdomain>
References: <20170316044704.GA729@jagdpanzerIV.localdomain>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 16 Mar 2017 09:27:32 +0100
Message-ID: <CACT4Y+asa7rDwjQi_09cYGsgqy0LFRRiCHq3=3t6__VUMLzmXg@mail.gmail.com>
Subject: Re: [mmotm] "x86/atomic: move __arch_atomic_add_unless out of line"
 build error
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20170315021431.13107-3-andi@firstfloor.org
Cc: Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 16, 2017 at 5:47 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> Hello,
>
> commit 4f86a82ff7df ("x86/atomic: move __arch_atomic_add_unless out of li=
ne")
> moved __arch_atomic_add_unless() out atomic.h and new KASAN atomic
> instrumentation [1] can't see it anymore
>
>
> In file included from ./arch/x86/include/asm/atomic.h:257:0,
>                  from ./include/linux/atomic.h:4,
>                  from ./include/asm-generic/qspinlock_types.h:28,
>                  from ./arch/x86/include/asm/spinlock_types.h:26,
>                  from ./include/linux/spinlock_types.h:13,
>                  from kernel/bounds.c:13:
> ./include/asm-generic/atomic-instrumented.h: In function =E2=80=98__atomi=
c_add_unless=E2=80=99:
> ./include/asm-generic/atomic-instrumented.h:70:9: error: implicit declara=
tion of function =E2=80=98__arch_atomic_add_unless=E2=80=99 [-Werror=3Dimpl=
icit-function-declaration]
>   return __arch_atomic_add_unless(v, a, u);
>          ^~~~~~~~~~~~~~~~~~~~~~~~
>
>
> so we need a declaration of __arch_atomic_add_unless() in arch/x86/includ=
e/asm/atomic.h
>
>
> [1] lkml.kernel.org/r/7e450175a324bf93c602909c711bc34715d8e8f2.1489519233=
.git.dvyukov@google.com
>
>         -ss


Andi, why did you completely remove __arch_atomic_add_unless() from
the header? Don't we need at least a declaration there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
