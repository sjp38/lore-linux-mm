Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD6096B0003
	for <linux-mm@kvack.org>; Sun,  4 Mar 2018 04:16:21 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id 184so11729458qki.0
        for <linux-mm@kvack.org>; Sun, 04 Mar 2018 01:16:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c24sor7881468qtg.150.2018.03.04.01.16.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Mar 2018 01:16:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sun, 4 Mar 2018 10:16:20 +0100
Message-ID: <CAMuHMdX-3uFCagtnR5fuuU9wPJZ41D45pGi-gst7vtc0VT7zmA@mail.gmail.com>
Subject: Re: [RFC PATCH 00/14] khwasan: kernel hardware assisted address sanitizer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux MM <linux-mm@kvack.org>, linux-kbuild <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

Hi Andrey,

On Fri, Mar 2, 2018 at 8:44 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> This patchset adds a new mode to KASAN, which is called KHWASAN (Kernel
> HardWare assisted Address SANitizer). There's still some work to do and
> there are a few TODOs in the code, so I'm publishing this as a RFC to
> collect some initial feedback.
>
> The plan is to implement HWASan [1] for the kernel with the incentive,
> that it's going to have comparable performance, but in the same time
> consume much less memory, trading that off for somewhat imprecise bug
> detection and being supported only for arm64.
>
> The overall idea of the approach used by KHWASAN is the following:
>
> 1. By using the Top Byte Ignore arm64 CPU feature, we can store pointer
>    tags in the top byte of each kernel pointer.

And for how long will this be OK?

Remembering:
  - AmigaBasic,
  - MacOS,
  - Emacs,
  - ...
They all tried to use the same trick, and did regret...
(AmigaBasic never survived this failure).

"Those who don't know history are doomed to repeat it."

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
