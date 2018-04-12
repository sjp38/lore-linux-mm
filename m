Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CEF186B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 13:37:30 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o132so5302762iod.11
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 10:37:30 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x2sor2006720ioc.258.2018.04.12.10.37.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Apr 2018 10:37:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a29d22c7-bcae-ec8d-1810-95eef013e699@virtuozzo.com>
References: <cover.1521828273.git.andreyknvl@google.com> <ba4a74ba1bc48dd66a3831143c3119d13c291fe3.1521828274.git.andreyknvl@google.com>
 <805d1e85-2d3c-2327-6e6c-f14a56dc0b67@virtuozzo.com> <CAAeHK+yg5ODeDy7k9fako5mcCLLnBrO729Zp_-UtDuzh3hZgZA@mail.gmail.com>
 <0c4397da-e231-0044-986f-b8468314be76@virtuozzo.com> <CAAeHK+xmCLe85_QNDam_BVTp9wVzjxgvko2+0JapJCzmciGa5g@mail.gmail.com>
 <0857f052-a27a-501e-8923-c6f31510e4fe@virtuozzo.com> <CAAeHK+xnHeznZwofNQVDcBCCMnaEQ6fcRxOcrFM-qQFUsZ51Rg@mail.gmail.com>
 <0f448799-3a06-a25d-d604-21db3e8577fc@virtuozzo.com> <CAAeHK+wWN=phNZgC_g5SMf61sCAVM7SGX9GdF1X4v+P3mK=uZA@mail.gmail.com>
 <bfc3da50-66df-c6ed-ad6a-a285efe617ec@virtuozzo.com> <CAAeHK+wzwXnJh1bbhUN6bm788q52BA2EfC+Q3dMS=peP7Px4Rg@mail.gmail.com>
 <a29d22c7-bcae-ec8d-1810-95eef013e699@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 12 Apr 2018 19:37:27 +0200
Message-ID: <CAAeHK+w1f4QSuan4onv-2ZxxSsi-ZYsdPOSuJ4=2ygJ2=q=VmA@mail.gmail.com>
Subject: Re: [RFC PATCH v2 13/15] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Thu, Apr 12, 2018 at 7:20 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>> 1. Tag memory with a random tag in kasan_alloc_pages() and returned a
>> tagged pointer from pagealloc.
>
> Tag memory with a random tag in kasan_alloc_pages() and store that tag in page struct (that part is also in kasan_alloc_pages()).
> page_address(page) will retrieve that tag from struct page to return tagged address.
>
> I've no idea what do you mean by "returning a tagged pointer from pagealloc".
> Once again, the page allocator (__alloc_pages_nodemask()) returns pointer to *struct page*,
> not the address in the linear mapping where is that page mapped (or not mapped at all if this is highmem).
> One have to call page_address()/kmap() to use that page.

Ah, that's what I've been missing.

OK, I'll do that.

Thanks!

>
>
>> 2. Restore the tag for the pointers returned from page_address for
>> !PageSlab() pages.
>>
>
> Right.
>
>> 3. Set the tag to 0xff for the pointers returned from page_address for
>> PageSlab() pages.
>>
>
> Right.
>
>> Is this correct?
>>
>> In 2 instead of storing the tag in page_struct, we can just recover it
>> from the shadow memory that corresponds to that page. What do you
>> think about this?
>
> Sounds ok. Don't see any problem with that.
>
>
