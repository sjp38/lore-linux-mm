Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 243E86B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:21:13 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id d18so19496446iob.23
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:21:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i1sor5918525iob.36.2018.03.06.10.21.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 10:21:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAMuHMdWoocn5pOvjx880CxUJL0LsPKd_UYs2fcWfHTF3cwFZBQ@mail.gmail.com>
References: <cover.1520017438.git.andreyknvl@google.com> <CAMuHMdX-3uFCagtnR5fuuU9wPJZ41D45pGi-gst7vtc0VT7zmA@mail.gmail.com>
 <20180304114439.zxksut65mefrpc7w@gmail.com> <CAMuHMdWoocn5pOvjx880CxUJL0LsPKd_UYs2fcWfHTF3cwFZBQ@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 6 Mar 2018 19:21:09 +0100
Message-ID: <CAAeHK+z4s1mAdL4tW79Vuf1AXd=wvfwT2dyyycuBt97kjs77PQ@mail.gmail.com>
Subject: Re: [RFC PATCH 00/14] khwasan: kernel hardware assisted address sanitizer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Ingo Molnar <mingo@kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux MM <linux-mm@kvack.org>, linux-kbuild <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Sun, Mar 4, 2018 at 4:49 PM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> Hi Ingo,
>
> On Sun, Mar 4, 2018 at 12:44 PM, Ingo Molnar <mingo@kernel.org> wrote:
>> * Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>>> On Fri, Mar 2, 2018 at 8:44 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>> >
>>> > The overall idea of the approach used by KHWASAN is the following:
>>> >
>>> > 1. By using the Top Byte Ignore arm64 CPU feature, we can store pointer
>>> >    tags in the top byte of each kernel pointer.
>>>
>>> And for how long will this be OK?
>>
>> Firstly it's not for production kernels, it's a hardware accelerator for an
>> intrusive debug feature, so it shouldn't really matter, right?
>
> Sorry, I didn't know it was a debug feature.

Hi!

Sorry, I'll add a description of what KASAN is in the next revision to
avoid confusion.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
