Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE82A6B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 10:17:13 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id s2-v6so14919460ioa.22
        for <linux-mm@kvack.org>; Tue, 22 May 2018 07:17:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k82-v6sor8966427iok.239.2018.05.22.07.17.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 May 2018 07:17:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a5c36c49-ee50-5298-424c-043a591f11e8@virtuozzo.com>
References: <cover.1525798753.git.andreyknvl@google.com> <427db6b29eaf61d77cb485e9e0a393d34741e498.1525798753.git.andreyknvl@google.com>
 <a5c36c49-ee50-5298-424c-043a591f11e8@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 22 May 2018 16:17:09 +0200
Message-ID: <CAAeHK+wChunKPn_iC_+qbtH-ek8SCo01mLdY=X-aX9bhPeznAQ@mail.gmail.com>
Subject: Re: [PATCH v1 01/16] khwasan, mm: change kasan hooks signatures
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Yury Norov <ynorov@caviumnetworks.com>, Marc Zyngier <marc.zyngier@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, James Morse <james.morse@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Julien Thierry <julien.thierry@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Sandipan Das <sandipan@linux.vnet.ibm.com>, David Woodhouse <dwmw@amazon.co.uk>, Paul Lawrence <paullawrence@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Laura Abbott <labbott@redhat.com>, Boris Brezillon <boris.brezillon@bootlin.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Agarwal <pintu.ping@gmail.com>, Doug Berger <opendmb@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

On Mon, May 14, 2018 at 6:56 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 05/08/2018 08:20 PM, Andrey Konovalov wrote:
>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 44aa7847324a..4fcd1442a761 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -1351,10 +1351,10 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
>>   * Hooks for other subsystems that check memory allocations. In a typical
>>   * production configuration these hooks all should produce no code at all.
>>   */
>> -static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
>> +static inline void kmalloc_large_node_hook(void **ptr, size_t size, gfp_t flags)
>>  {
>> -     kmemleak_alloc(ptr, size, 1, flags);
>> -     kasan_kmalloc_large(ptr, size, flags);
>> +     kmemleak_alloc(*ptr, size, 1, flags);
>> +     *ptr = kasan_kmalloc_large(*ptr, size, flags);
>
> Why not 'return ptr' like everywhere else?

Will fix in v2, thanks!
