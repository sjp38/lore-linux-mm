Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68ACB6B42E8
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 19:01:57 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id q21-v6so355427pff.21
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 16:01:57 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c31-v6si446713pgl.126.2018.08.27.16.01.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 16:01:55 -0700 (PDT)
Received: from mail-wr1-f41.google.com (mail-wr1-f41.google.com [209.85.221.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E268D208E2
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 23:01:54 +0000 (UTC)
Received: by mail-wr1-f41.google.com with SMTP id u12-v6so506314wrr.4
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 16:01:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2998E63A-5663-4805-9DE7-829A5870AA6D@gmail.com>
References: <D74A89DF-0D89-4AB6-8A6B-93BEC9A83595@gmail.com>
 <20180824180438.GS24124@hirez.programming.kicks-ass.net> <56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com>
 <CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com>
 <9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com> <CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
 <8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com> <CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com>
 <20180826112341.f77a528763e297cbc36058fa@kernel.org> <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
 <20180826090958.GT24124@hirez.programming.kicks-ass.net> <20180827120305.01a6f26267c64610cadec5d8@kernel.org>
 <4BF82052-4738-441C-8763-26C85003F2C9@gmail.com> <20180827170511.6bafa15cbc102ae135366e86@kernel.org>
 <01DA0BDD-7504-4209-8A8F-20B27CF6A1C7@gmail.com> <CALCETrWxwpr+Xx0mCK1HUkanmCDOSRbw50VmebgoAgeNaaPAKg@mail.gmail.com>
 <0000D631-FDDF-4273-8F3C-714E6825E59B@gmail.com> <CALCETrUoNdwDuNSHb3haw9-fYk+sNC_M4r+5EMVVzJ8HWeSsOQ@mail.gmail.com>
 <823D916E-4056-4A36-BDD8-0FB682A8DCAE@gmail.com> <E5B40DF6-C28A-4EB2-84C3-146BC5B8B312@gmail.com>
 <CALCETrW+nx7kRWov_+hCAxJRUSsUUJuVqvRP7KoVUxvFFTqi5Q@mail.gmail.com>
 <08A6BCB2-66C2-47ED-AEB8-AA8F4D7DBD45@gmail.com> <4F72D40A-25A3-4C64-B8DD-56970CFDE61E@gmail.com>
 <CALCETrWaYgyaGcHYdvbcwXBEwHx61qbX_T99+XGD7qnRpRVGuA@mail.gmail.com> <2998E63A-5663-4805-9DE7-829A5870AA6D@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 27 Aug 2018 16:01:32 -0700
Message-ID: <CALCETrUBGFFf_M4V2dz6Uath18JK0kCNJB=GxXqfybgbsZZkiw@mail.gmail.com>
Subject: Re: TLB flushes on fixmap changes
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Mon, Aug 27, 2018 at 3:54 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
> at 3:32 PM, Andy Lutomirski <luto@kernel.org> wrote:
>
>> On Mon, Aug 27, 2018 at 2:55 PM, Nadav Amit <nadav.amit@gmail.com> wrote=
:
>>> at 1:16 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
>>>
>>>> at 12:58 PM, Andy Lutomirski <luto@kernel.org> wrote:
>>>>
>>>>> On Mon, Aug 27, 2018 at 12:43 PM, Nadav Amit <nadav.amit@gmail.com> w=
rote:
>>>>>> at 12:10 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
>>>>>>
>>>>>>> at 11:58 AM, Andy Lutomirski <luto@kernel.org> wrote:
>>>>>>>
>>>>>>>> On Mon, Aug 27, 2018 at 11:54 AM, Nadav Amit <nadav.amit@gmail.com=
> wrote:
>>>>>>>>>> On Mon, Aug 27, 2018 at 10:34 AM, Nadav Amit <nadav.amit@gmail.c=
om> wrote:
>>>>>>>>>> What do you all think?
>>>>>>>>>
>>>>>>>>> I agree in general. But I think that current->mm would need to be=
 loaded, as
>>>>>>>>> otherwise I am afraid it would break switch_mm_irqs_off().
>>>>>>>>
>>>>>>>> What breaks?
>>>>>>>
>>>>>>> Actually nothing. I just saw the IBPB stuff regarding tsk, but it s=
hould not
>>>>>>> matter.
>>>>>>
>>>>>> So here is what I got. It certainly needs some cleanup, but it boots=
.
>>>>>>
>>>>>> Let me know how crappy you find it...
>>>>>>
>>>>>>
>>>>>> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/a=
sm/mmu_context.h
>>>>>> index bbc796eb0a3b..336779650a41 100644
>>>>>> --- a/arch/x86/include/asm/mmu_context.h
>>>>>> +++ b/arch/x86/include/asm/mmu_context.h
>>>>>> @@ -343,4 +343,24 @@ static inline unsigned long __get_current_cr3_f=
ast(void)
>>>>>>      return cr3;
>>>>>> }
>>>>>>
>>>>>> +typedef struct {
>>>>>> +       struct mm_struct *prev;
>>>>>> +} temporary_mm_state_t;
>>>>>> +
>>>>>> +static inline temporary_mm_state_t use_temporary_mm(struct mm_struc=
t *mm)
>>>>>> +{
>>>>>> +       temporary_mm_state_t state;
>>>>>> +
>>>>>> +       lockdep_assert_irqs_disabled();
>>>>>> +       state.prev =3D this_cpu_read(cpu_tlbstate.loaded_mm);
>>>>>> +       switch_mm_irqs_off(NULL, mm, current);
>>>>>> +       return state;
>>>>>> +}
>>>>>> +
>>>>>> +static inline void unuse_temporary_mm(temporary_mm_state_t prev)
>>>>>> +{
>>>>>> +       lockdep_assert_irqs_disabled();
>>>>>> +       switch_mm_irqs_off(NULL, prev.prev, current);
>>>>>> +}
>>>>>> +
>>>>>> #endif /* _ASM_X86_MMU_CONTEXT_H */
>>>>>> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/p=
gtable.h
>>>>>> index 5715647fc4fe..ef62af9a0ef7 100644
>>>>>> --- a/arch/x86/include/asm/pgtable.h
>>>>>> +++ b/arch/x86/include/asm/pgtable.h
>>>>>> @@ -976,6 +976,10 @@ static inline void __meminit init_trampoline_de=
fault(void)
>>>>>>      /* Default trampoline pgd value */
>>>>>>      trampoline_pgd_entry =3D init_top_pgt[pgd_index(__PAGE_OFFSET)]=
;
>>>>>> }
>>>>>> +
>>>>>> +void __init patching_mm_init(void);
>>>>>> +#define patching_mm_init patching_mm_init
>>>>>> +
>>>>>> # ifdef CONFIG_RANDOMIZE_MEMORY
>>>>>> void __meminit init_trampoline(void);
>>>>>> # else
>>>>>> diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/incl=
ude/asm/pgtable_64_types.h
>>>>>> index 054765ab2da2..9f44262abde0 100644
>>>>>> --- a/arch/x86/include/asm/pgtable_64_types.h
>>>>>> +++ b/arch/x86/include/asm/pgtable_64_types.h
>>>>>> @@ -116,6 +116,9 @@ extern unsigned int ptrs_per_p4d;
>>>>>> #define LDT_PGD_ENTRY          (pgtable_l5_enabled() ? LDT_PGD_ENTRY=
_L5 : LDT_PGD_ENTRY_L4)
>>>>>> #define LDT_BASE_ADDR          (LDT_PGD_ENTRY << PGDIR_SHIFT)
>>>>>>
>>>>>> +#define TEXT_POKE_PGD_ENTRY    -5UL
>>>>>> +#define TEXT_POKE_ADDR         (TEXT_POKE_PGD_ENTRY << PGDIR_SHIFT)
>>>>>> +
>>>>>> #define __VMALLOC_BASE_L4      0xffffc90000000000UL
>>>>>> #define __VMALLOC_BASE_L5      0xffa0000000000000UL
>>>>>>
>>>>>> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include=
/asm/pgtable_types.h
>>>>>> index 99fff853c944..840c72ec8c4f 100644
>>>>>> --- a/arch/x86/include/asm/pgtable_types.h
>>>>>> +++ b/arch/x86/include/asm/pgtable_types.h
>>>>>> @@ -505,6 +505,9 @@ pgprot_t phys_mem_access_prot(struct file *file,=
 unsigned long pfn,
>>>>>> /* Install a pte for a particular vaddr in kernel space. */
>>>>>> void set_pte_vaddr(unsigned long vaddr, pte_t pte);
>>>>>>
>>>>>> +struct mm_struct;
>>>>>> +void set_mm_pte_vaddr(struct mm_struct *mm, unsigned long vaddr, pt=
e_t pte);
>>>>>> +
>>>>>> #ifdef CONFIG_X86_32
>>>>>> extern void native_pagetable_init(void);
>>>>>> #else
>>>>>> diff --git a/arch/x86/include/asm/text-patching.h b/arch/x86/include=
/asm/text-patching.h
>>>>>> index 2ecd34e2d46c..cb364ea5b19d 100644
>>>>>> --- a/arch/x86/include/asm/text-patching.h
>>>>>> +++ b/arch/x86/include/asm/text-patching.h
>>>>>> @@ -38,4 +38,6 @@ extern void *text_poke(void *addr, const void *opc=
ode, size_t len);
>>>>>> extern int poke_int3_handler(struct pt_regs *regs);
>>>>>> extern void *text_poke_bp(void *addr, const void *opcode, size_t len=
, void *handler);
>>>>>>
>>>>>> +extern struct mm_struct *patching_mm;
>>>>>> +
>>>>>> #endif /* _ASM_X86_TEXT_PATCHING_H */
>>>>>> diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alterna=
tive.c
>>>>>> index a481763a3776..fd8a950b0d62 100644
>>>>>> --- a/arch/x86/kernel/alternative.c
>>>>>> +++ b/arch/x86/kernel/alternative.c
>>>>>> @@ -11,6 +11,7 @@
>>>>>> #include <linux/stop_machine.h>
>>>>>> #include <linux/slab.h>
>>>>>> #include <linux/kdebug.h>
>>>>>> +#include <linux/mmu_context.h>
>>>>>> #include <asm/text-patching.h>
>>>>>> #include <asm/alternative.h>
>>>>>> #include <asm/sections.h>
>>>>>> @@ -701,8 +702,36 @@ void *text_poke(void *addr, const void *opcode,=
 size_t len)
>>>>>>              WARN_ON(!PageReserved(pages[0]));
>>>>>>              pages[1] =3D virt_to_page(addr + PAGE_SIZE);
>>>>>>      }
>>>>>> -       BUG_ON(!pages[0]);
>>>>>> +
>>>>>>      local_irq_save(flags);
>>>>>> +       BUG_ON(!pages[0]);
>>>>>> +
>>>>>> +       /*
>>>>>> +        * During initial boot, it is hard to initialize patching_mm=
 due to
>>>>>> +        * dependencies in boot order.
>>>>>> +        */
>>>>>> +       if (patching_mm) {
>>>>>> +               pte_t pte;
>>>>>> +               temporary_mm_state_t prev;
>>>>>> +
>>>>>> +               prev =3D use_temporary_mm(patching_mm);
>>>>>> +               pte =3D mk_pte(pages[0], PAGE_KERNEL);
>>>>>> +               set_mm_pte_vaddr(patching_mm, TEXT_POKE_ADDR, pte);
>>>>>> +               pte =3D mk_pte(pages[1], PAGE_KERNEL);
>>>>>> +               set_mm_pte_vaddr(patching_mm, TEXT_POKE_ADDR + PAGE_=
SIZE, pte);
>>>>>> +
>>>>>> +               memcpy((void *)(TEXT_POKE_ADDR | ((unsigned long)add=
r & ~PAGE_MASK)),
>>>>>> +                      opcode, len);
>>>>>> +
>>>>>> +               set_mm_pte_vaddr(patching_mm, TEXT_POKE_ADDR, __pte(=
0));
>>>>>> +               set_mm_pte_vaddr(patching_mm, TEXT_POKE_ADDR + PAGE_=
SIZE, __pte(0));
>>>>>> +               local_flush_tlb();
>>>>>
>>>>> Hmm.  This is stuff busted on SMP, and it's IMO more complicated than
>>>>> needed.  How about getting rid of all the weird TLB flushing stuff an=
d
>>>>> instead putting the mapping at vaddr - __START_KERNEL_map or whatever
>>>>> it is?  You *might* need to flush_tlb_mm_range() on module unload, bu=
t
>>>>> that's it.
>>>>
>>>> I don=E2=80=99t see what=E2=80=99s wrong in SMP, since this entire pie=
ce of code should be
>>>> running under text_mutex.
>>>>
>>>> I don=E2=80=99t quite understand your proposal. I really don=E2=80=99t=
 want to have any
>>>> chance in which the page-tables for the poked address is not prealloca=
ted.
>>>>
>>>> It is more complicated than needed, and there are redundant TLB flushe=
s. The
>>>> reason I preferred to do it this way, is in order not to use other fun=
ctions
>>>> that take locks during the software page-walk and not to duplicate exi=
sting
>>>> code. Yet, duplication might be the way to go.
>>>>
>>>>>> +               sync_core();
>>>>>
>>>>> I can't think of any case where sync_core() is needed.  The mm switch
>>>>> serializes.
>>>>
>>>> Good point!
>>>>
>>>>> Also, is there any circumstance in which any of this is used before a=
t
>>>>> least jump table init?  All the early stuff is text_poke_early(),
>>>>> right?
>>>>
>>>> Not before jump_label_init. However, I did not manage to get rid of th=
e two
>>>> code-patches in text_poke(), since text_poke is used relatively early =
by
>>>> x86_late_time_init(), and at this stage kmem_cache_alloc() - which is =
needed
>>>> to duplicate init_mm - still fails.
>>>
>>> Another correction: the populate_extra_pte() is not needed.
>>>
>>> Anyhow, if you want to do this whole thing differently, I obviously wil=
l not
>>> object, but I think it will end up more complicated.
>>>
>>> I think I finally understood your comment about "vaddr -
>>> __START_KERNEL_map=E2=80=9D. I did something like that before, and it i=
s not
>>> super-simple. You need not only to conditionally flush the TLB, but als=
o
>>> to synchronize the PUD/PMD on changes. Don=E2=80=99t forget that module=
 memory
>>> is installed even when BPF programs are installed.
>>>
>>> Let me know if you want me to submit cleaner patches or you want to car=
ry on
>>> yourself.
>>
>> I think your approach is a good start and should be good enough (with
>> cleanups) as a fix for the bug.  But I think your code has the same
>> bug that we have now!  You're reusing the same address on multiple
>> CPUs without flushing.  You can easily fix it by forcing a flush
>> before loading the mm, which should be as simple as adding
>> flush_tlb_mm() before you load the mm.  (It won't actually flush
>> anything by itself, since the mm isn't loaded, but it will update the
>> bookkeeping so that switch_mm_irqs_off() flushes the mm.)
>
> What am I missing?
>
> We have a lock (text_mutex) which prevents the use of the new page-table
> hierarchy on multiple CPUs. In addition we have __set_pte_vaddr() which d=
oes
> a local TLB flush before the lock is released and before IRQs are enabled=
.
> So how can the PTE be cached on multiple CPUs?
>
> Yes, __set_pte_vaddr() is ugly and flushes too much. I=E2=80=99ll try to =
remove some
> redundant TLB flushes, but these flushes are already there.

I missed that set_pte_vaddr() contained a flush.  It's probably nicer
to use one of the APIs that doesn't imply a flush.  If you end up with
vm_insert_pfn() or similar, you can use can use copy_to_user() if
needed :)

>
>> Also, please at least get rid of TEXT_POKE_ADDR.  If you don't want to
>> do the vaddr - __START_KERNEL_map thing, then at least pick an address
>> in the low half of the address space such as 0 :)  Ideally you'd only
>> use this thing late enough that you could even use the normal
>> insert_pfn (or similar) API for it, but that doesn't really matter.
>
> Perhaps the vaddr - __START_KERNEL_map actually makes sense. I was
> misunderstanding it (again) before, thinking you want me to use vaddr (an=
d
> not the delta). I=E2=80=99ll give it a try.

It does prevent easy preallocation of the intermediate tables.

And do we really allow text_poke() / text_poke_bp() on BPF programs?  Hmm.
