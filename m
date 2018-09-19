Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 170578E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 13:27:55 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id z20-v6so7199522iol.1
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 10:27:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 195-v6sor6081566itz.80.2018.09.19.10.27.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 10:27:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Z4zLSBdXGtk-6nH64UpOVA8s5TJZSpokAqEu4pE8LpCA@mail.gmail.com>
References: <cover.1535462971.git.andreyknvl@google.com> <b4ba65afa55f2fdfd2856fb03c5aba99c7a8bdd7.1535462971.git.andreyknvl@google.com>
 <CACT4Y+Z4zLSBdXGtk-6nH64UpOVA8s5TJZSpokAqEu4pE8LpCA@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 19 Sep 2018 19:27:52 +0200
Message-ID: <CAAeHK+ySaS_jUe_wNQ192kE4bUgZUOMdSyQeRp5Tx2nCD41vBQ@mail.gmail.com>
Subject: Re: [PATCH v6 04/18] khwasan, arm64: adjust shadow size for CONFIG_KASAN_HW
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Sep 12, 2018 at 4:54 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:

>>  /*
>> - * KASAN requires 1/8th of the kernel virtual address space for the shadow
>> - * region. KASAN can bloat the stack significantly, so double the (minimum)
>> - * stack size when KASAN is in use.
>> + * KASAN and KHWASAN require 1/8th and 1/16th of the kernel virtual address
>
>
> I am somewhat confused by the terminology.
> "KASAN" is not actually "CONFIG_KASAN" below, it is actually
> "CONFIG_KASAN_GENERIC". While "KHWASAN" translates to "KASAN_HW" few
> lines later.
> I think we need some consistent terminology for comments and config
> names until it's too late.
>

As per offline discussion will rename in v7.
