Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4C9B6B0003
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 09:10:54 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id t9so3851258ioa.9
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 06:10:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 26sor1344765ioq.234.2018.03.12.06.10.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Mar 2018 06:10:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180309191823.p6r7f5dlxhifxokh@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com> <1943a345f4fb7e8e8f19b4ece2457bccd772f0dc.1520017438.git.andreyknvl@google.com>
 <20180305145435.tfaldb334lp4obhi@lakrids.cambridge.arm.com>
 <CAAeHK+y+sAGYSsfUHk4De2QiAPEN_+_ACxCoQ7XMSkvpseoFVQ@mail.gmail.com> <20180309191823.p6r7f5dlxhifxokh@lakrids.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 12 Mar 2018 14:10:50 +0100
Message-ID: <CAAeHK+zZA3mqEiXddaENBnAGUyG5fQobNRJ8heJ9oOkyG6Fq0Q@mail.gmail.com>
Subject: Re: [RFC PATCH 14/14] khwasan: default the instrumentation mode to inline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 9, 2018 at 8:18 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Fri, Mar 09, 2018 at 07:06:59PM +0100, Andrey Konovalov wrote:
>> On Mon, Mar 5, 2018 at 3:54 PM, Mark Rutland <mark.rutland@arm.com> wrote:
>>
>> Hi Mark!
>>
>> GCC before 5.0 doesn't support KASAN_INLINE, but AFAIU will fallback
>> to outline instrumentation in this case.
>>
>> Latest Clang Release doesn't support KASAN_INLINE (although current
>> trunk does) and falls back to outline instrumentation.
>>
>> So nothing should break, but people with newer compilers should get
>> the benefits of using the inline instrumentation by default.
>
> Ah, ok. I had assumed that they were separate compiler options, and this
> would result in a build failure.

No worries, I'll check that GCC 4.9 works and add this info to the
commit message.

>
> I have no strong feelings either way as to the default. I typically use
> inline today unless I'm trying to debug particularly weird cases and
> want to hack the shadow accesses.

Great!

>
> Thanks,
> Mark.
