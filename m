Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3CD6B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 10:38:35 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i200-v6so55886itb.9
        for <linux-mm@kvack.org>; Tue, 22 May 2018 07:38:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18-v6sor46363itc.92.2018.05.22.07.38.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 May 2018 07:38:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <69a5a7d3-e2ae-1100-f56f-9edfb0c4b3dd@virtuozzo.com>
References: <cover.1525798753.git.andreyknvl@google.com> <454315e28d8bdd8e507de2e29f718f1fcae17d58.1525798753.git.andreyknvl@google.com>
 <69a5a7d3-e2ae-1100-f56f-9edfb0c4b3dd@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 22 May 2018 16:38:33 +0200
Message-ID: <CAAeHK+zJe9PjMOgivsihE3JMD2KwTGj4Hrm+Bq53U3Bghz0c4w@mail.gmail.com>
Subject: Re: [PATCH v1 02/16] khwasan: move common kasan and khwasan code to common.c
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Yury Norov <ynorov@caviumnetworks.com>, Marc Zyngier <marc.zyngier@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, James Morse <james.morse@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Julien Thierry <julien.thierry@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Sandipan Das <sandipan@linux.vnet.ibm.com>, David Woodhouse <dwmw@amazon.co.uk>, Paul Lawrence <paullawrence@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Laura Abbott <labbott@redhat.com>, Boris Brezillon <boris.brezillon@bootlin.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Agarwal <pintu.ping@gmail.com>, Doug Berger <opendmb@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

On Tue, May 15, 2018 at 3:28 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 05/08/2018 08:20 PM, Andrey Konovalov wrote:
>
>> +
>> +void set_track(struct kasan_track *track, gfp_t flags)
>
> This was -  static inline void set_track(struct kasan_track *track, gfp_t flags)
> and still used only locally.
>
>> +{
>> +     track->pid = current->pid;
>> +     track->stack = save_stack(flags);
>> +}
>> +

Will fix in v2.

>
>
>
>>  /*
>>   * Adaptive redzone policy taken from the userspace AddressSanitizer runtime.
>>   * For larger allocations larger redzones are used.
>>   */
>> -static unsigned int optimal_redzone(unsigned int object_size)
>> +unsigned int optimal_redzone(unsigned int object_size)
>
> I'd rather move this in common too.
> For khwasan you could just add:
>         if (IS_ENABLED(CONFIG_KASAN_HW))
>                 return 0;
>
>

Will move in v2.
