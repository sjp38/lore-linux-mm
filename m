Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2DE6B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 10:25:58 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f9-v6so15246536iob.14
        for <linux-mm@kvack.org>; Tue, 22 May 2018 07:25:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f80-v6sor40142ita.15.2018.05.22.07.25.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 May 2018 07:25:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <658f02bd-e647-52e6-87cf-5d91f8243b66@virtuozzo.com>
References: <cover.1525798753.git.andreyknvl@google.com> <b31260f782783e21ca2e2a45f9b05016998bf9ed.1525798753.git.andreyknvl@google.com>
 <658f02bd-e647-52e6-87cf-5d91f8243b66@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 22 May 2018 16:25:54 +0200
Message-ID: <CAAeHK+yW_kOrL58fkvmJ=84RXzijFTHCd85Ahp3Bj1E79QeziA@mail.gmail.com>
Subject: Re: [PATCH v1 03/16] khwasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_HW
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Yury Norov <ynorov@caviumnetworks.com>, Marc Zyngier <marc.zyngier@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, James Morse <james.morse@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Julien Thierry <julien.thierry@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Sandipan Das <sandipan@linux.vnet.ibm.com>, David Woodhouse <dwmw@amazon.co.uk>, Paul Lawrence <paullawrence@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Laura Abbott <labbott@redhat.com>, Boris Brezillon <boris.brezillon@bootlin.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Agarwal <pintu.ping@gmail.com>, Doug Berger <opendmb@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

On Mon, May 14, 2018 at 6:57 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 05/08/2018 08:20 PM, Andrey Konovalov wrote:
>
>> diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
>> index 69552a39951d..47023daf5606 100644
>> --- a/scripts/Makefile.kasan
>> +++ b/scripts/Makefile.kasan
>> @@ -1,5 +1,5 @@
>>  # SPDX-License-Identifier: GPL-2.0
>> -ifdef CONFIG_KASAN
>> +ifdef CONFIG_KASAN_GENERIC
>>  ifdef CONFIG_KASAN_INLINE
>>       call_threshold := 10000
>>  else
>> @@ -45,3 +45,28 @@ endif
>>  CFLAGS_KASAN_NOSANITIZE := -fno-builtin
>>
>>  endif
>> +
>> +ifdef CONFIG_KASAN_HW
>> +
>> +ifdef CONFIG_KASAN_INLINE
>> +    instrumentation_flags := -mllvm -hwasan-mapping-offset=$(KASAN_SHADOW_OFFSET)
>> +else
>> +    instrumentation_flags := -mllvm -hwasan-instrument-with-calls=1
>> +endif
>> +
>> +CFLAGS_KASAN_MINIMAL := -fsanitize=kernel-hwaddress
>> +
>> +ifeq ($(call cc-option, $(CFLAGS_KASAN_MINIMAL) -Werror),)
>> +    ifneq ($(CONFIG_COMPILE_TEST),y)
>> +        $(warning Cannot use CONFIG_KASAN_HW: \
>> +            -fsanitize=hwaddress is not supported by compiler)
>> +    endif
>> +else
>> +    CFLAGS_KASAN := $(call cc-option, -fsanitize=kernel-hwaddress \
>> +        -mllvm -hwasan-instrument-stack=0 \
>> +        $(instrumentation_flags))
>> +endif
>
> So this code does the following:
>  1) Warn if compiler doesn't support -fsanitize=kernel-hwaddress
>  2) Compile the kernel with all necessary set of the '-fsanitize=kernel-hwaddress -mllvm -hwasan-*' flags if compiler supports all of them.
>  3) Compile the kernel with empty CFLAGS_KASAN without a warning if compiler supports 'fsanitize=kernel-hwaddress',
>      but doesn't support the rest '-mllvm -hwasan-*' flags.
>
> The last one is just nonsense.

Should I remove "call cc-option" to fix this?

>
>
>> +
>> +CFLAGS_KASAN_NOSANITIZE := -fno-builtin
>> +
>
> Does it really has to declared twice?

Will fix in v2.
