Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBB656B0007
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 09:58:21 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id q5-v6so8411052itq.2
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 06:58:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v25-v6sor5180756iog.107.2018.06.04.06.58.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Jun 2018 06:58:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <ec94bd47-f3a0-a75a-17b7-59765ec32c15@codeaurora.org>
References: <cover.1527259068.git.andreyknvl@google.com> <2ef4932c434047ca5a2062782206b4163263dc57.1527259068.git.andreyknvl@google.com>
 <ec94bd47-f3a0-a75a-17b7-59765ec32c15@codeaurora.org>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 4 Jun 2018 15:58:18 +0200
Message-ID: <CAAeHK+y=yZAgh4xzfqjEAtcLXeaUSWgJcUyTSsWfLqrpZS88eg@mail.gmail.com>
Subject: Re: [PATCH v2 03/16] khwasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_HW
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Yury Norov <ynorov@caviumnetworks.com>, Marc Zyngier <marc.zyngier@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, James Morse <james.morse@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Julien Thierry <julien.thierry@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Sandipan Das <sandipan@linux.vnet.ibm.com>, David Woodhouse <dwmw@amazon.co.uk>, Paul Lawrence <paullawrence@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Laura Abbott <labbott@redhat.com>, Boris Brezillon <boris.brezillon@bootlin.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Agarwal <pintu.ping@gmail.com>, Doug Berger <opendmb@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Mon, Jun 4, 2018 at 12:27 PM, Chintan Pandya <cpandya@codeaurora.org> wrote:
>
>
> On 5/25/2018 8:10 PM, Andrey Konovalov wrote:
> ...<snip>
>
>> +ifdef CONFIG_KASAN_HW
>> +
>> +ifdef CONFIG_KASAN_INLINE
>> +    instrumentation_flags := -mllvm
>> -hwasan-mapping-offset=$(KASAN_SHADOW_OFFSET)
>> +else
>> +    instrumentation_flags := -mllvm -hwasan-instrument-with-calls=1
>> +endif
>>   +CFLAGS_KASAN := -fsanitize=kernel-hwaddress \
>> +               -mllvm -hwasan-instrument-stack=0 \
>> +               $(instrumentation_flags)
>> +
>> +ifeq ($(call cc-option, $(CFLAGS_KASAN_MINIMAL) -Werror),)
>
>
> /s/CFLAGS_KASAN_MINIMAL/CFLAGS_KASAN ??
>

Right, thanks! Will fix in v3.
