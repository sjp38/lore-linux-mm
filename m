Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFFD6B0033
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 02:35:17 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id s12so23035019plp.11
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 23:35:17 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l64sor5534098pge.240.2017.12.27.23.35.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Dec 2017 23:35:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <94eb2c07793623fa000561618401@google.com>
References: <94eb2c07793623fa000561618401@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 28 Dec 2017 08:34:53 +0100
Message-ID: <CACT4Y+Z=Sc2W-+sq=hayGkJA4X+mkfaUY65y=J220U-rDA23oQ@mail.gmail.com>
Subject: Re: mmots build error (2)
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+29c5e7133d56d150a59e@syzkaller.appspotmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, syzkaller-bugs@googlegroups.com

On Thu, Dec 28, 2017 at 8:32 AM, syzbot
<syzbot+29c5e7133d56d150a59e@syzkaller.appspotmail.com> wrote:
> Hello,
>
> syzkaller hit the following crash on
> 253f36c7c1aee654871b4f0c5e16ee6c396bff9a
> git://git.cmpxchg.org/linux-mmots.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> Unfortunately, I don't have any reproducer for this bug yet.
>
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit=
:
> Reported-by: <syzbot+29c5e7133d56d150a59e@syzkaller.appspotmail.com>
> It will help syzbot understand when the bug is fixed. See footer for
> details.
> If you forward the report, please keep this part and the footer.


+mm
the build is broken as:

failed to run /usr/bin/make [make bzImage -j 32
CC=3D/syzkaller/gcc/bin/gcc]: exit status 2
scripts/kconfig/conf  --silentoldconfig Kconfig
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  UPD     include/config/kernel.release
  CHK     include/generated/utsrelease.h
  UPD     include/generated/utsrelease.h
  CC      kernel/bounds.s
  CHK     include/generated/timeconst.h
  CC      scripts/mod/empty.o
  CC      scripts/mod/devicetable-offsets.s
  MKELF   scripts/mod/elfconfig.h
  HOSTCC  scripts/mod/modpost.o
  HOSTCC  scripts/mod/sumversion.o
  CHK     scripts/mod/devicetable-offsets.h
  HOSTCC  scripts/mod/file2alias.o
  HOSTLD  scripts/mod/modpost
  CHK     include/generated/bounds.h
  CC      arch/x86/kernel/asm-offsets.s
In file included from ./arch/x86/include/asm/pgtable_types.h:250:0,
                 from ./arch/x86/include/asm/paravirt_types.h:45,
                 from ./arch/x86/include/asm/ptrace.h:92,
                 from ./arch/x86/include/asm/math_emu.h:5,
                 from ./arch/x86/include/asm/processor.h:12,
                 from ./arch/x86/include/asm/cpufeature.h:5,
                 from ./arch/x86/include/asm/thread_info.h:53,
                 from ./include/linux/thread_info.h:38,
                 from ./arch/x86/include/asm/preempt.h:7,
                 from ./include/linux/preempt.h:81,
                 from ./include/linux/spinlock.h:51,
                 from ./include/linux/mmzone.h:8,
                 from ./include/linux/gfp.h:6,
                 from ./include/linux/slab.h:15,
                 from ./include/linux/crypto.h:24,
                 from arch/x86/kernel/asm-offsets.c:9:
./arch/x86/include/asm/pgtable_64_types.h:97:1: error: version control
conflict marker in file
 <<<<<<< HEAD
 ^~~~~~~
In file included from ./arch/x86/include/asm/paravirt_types.h:45:0,
                 from ./arch/x86/include/asm/ptrace.h:92,
                 from ./arch/x86/include/asm/math_emu.h:5,
                 from ./arch/x86/include/asm/processor.h:12,
                 from ./arch/x86/include/asm/cpufeature.h:5,
                 from ./arch/x86/include/asm/thread_info.h:53,
                 from ./include/linux/thread_info.h:38,
                 from ./arch/x86/include/asm/preempt.h:7,
                 from ./include/linux/preempt.h:81,
                 from ./include/linux/spinlock.h:51,
                 from ./include/linux/mmzone.h:8,
                 from ./include/linux/gfp.h:6,
                 from ./include/linux/slab.h:15,
                 from ./include/linux/crypto.h:24,
                 from arch/x86/kernel/asm-offsets.c:9:
./arch/x86/include/asm/pgtable_types.h:266:47: warning: data
definition has no type or storage class
 typedef struct pgprot { pgprotval_t pgprot; } pgprot_t;
                                               ^~~~~~~~
./arch/x86/include/asm/pgtable_types.h:266:47: error: type defaults to
=E2=80=98int=E2=80=99 in declaration of =E2=80=98pgprot_t=E2=80=99 [-Werror=
=3Dimplicit-int]
In file included from ./arch/x86/include/asm/paravirt_types.h:45:0,
                 from ./arch/x86/include/asm/ptrace.h:92,
                 from ./arch/x86/include/asm/math_emu.h:5,
                 from ./arch/x86/include/asm/processor.h:12,
                 from ./arch/x86/include/asm/cpufeature.h:5,
                 from ./arch/x86/include/asm/thread_info.h:53,
                 from ./include/linux/thread_info.h:38,
                 from ./arch/x86/include/asm/preempt.h:7,
                 from ./include/linux/preempt.h:81,
                 from ./include/linux/spinlock.h:51,
                 from ./include/linux/mmzone.h:8,
                 from ./include/linux/gfp.h:6,
                 from ./include/linux/slab.h:15,
                 from ./include/linux/crypto.h:24,
                 from arch/x86/kernel/asm-offsets.c:9:
./arch/x86/include/asm/pgtable_types.h:441:24: error: expected =E2=80=98=3D=
=E2=80=99,
=E2=80=98,=E2=80=99, =E2=80=98;=E2=80=99, =E2=80=98asm=E2=80=99 or =E2=80=
=98__attribute__=E2=80=99 before =E2=80=98cachemode2pgprot=E2=80=99
 static inline pgprot_t cachemode2pgprot(enum page_cache_mode pcm)
                        ^~~~~~~~~~~~~~~~
./arch/x86/include/asm/pgtable_types.h:445:53: error: expected
declaration specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=
=80=99
 static inline enum page_cache_mode pgprot2cachemode(pgprot_t pgprot)
                                                     ^~~~~~~~
./arch/x86/include/asm/pgtable_types.h:454:24: error: expected =E2=80=98=3D=
=E2=80=99,
=E2=80=98,=E2=80=99, =E2=80=98;=E2=80=99, =E2=80=98asm=E2=80=99 or =E2=80=
=98__attribute__=E2=80=99 before =E2=80=98pgprot_4k_2_large=E2=80=99
 static inline pgprot_t pgprot_4k_2_large(pgprot_t pgprot)
                        ^~~~~~~~~~~~~~~~~
./arch/x86/include/asm/pgtable_types.h:463:24: error: expected =E2=80=98=3D=
=E2=80=99,
=E2=80=98,=E2=80=99, =E2=80=98;=E2=80=99, =E2=80=98asm=E2=80=99 or =E2=80=
=98__attribute__=E2=80=99 before =E2=80=98pgprot_large_2_4k=E2=80=99
 static inline pgprot_t pgprot_large_2_4k(pgprot_t pgprot)
                        ^~~~~~~~~~~~~~~~~
./arch/x86/include/asm/pgtable_types.h:481:29: error: expected =E2=80=98=3D=
=E2=80=99,
=E2=80=98,=E2=80=99, =E2=80=98;=E2=80=99, =E2=80=98asm=E2=80=99 or =E2=80=
=98__attribute__=E2=80=99 before =E2=80=98pgprot_writecombine=E2=80=99
 #define pgprot_writecombine pgprot_writecombine
                             ^
./arch/x86/include/asm/pgtable_types.h:482:17: note: in expansion of
macro =E2=80=98pgprot_writecombine=E2=80=99
 extern pgprot_t pgprot_writecombine(pgprot_t prot);
                 ^~~~~~~~~~~~~~~~~~~
./arch/x86/include/asm/pgtable_types.h:484:29: error: expected =E2=80=98=3D=
=E2=80=99,
=E2=80=98,=E2=80=99, =E2=80=98;=E2=80=99, =E2=80=98asm=E2=80=99 or =E2=80=
=98__attribute__=E2=80=99 before =E2=80=98pgprot_writethrough=E2=80=99
 #define pgprot_writethrough pgprot_writethrough
                             ^
./arch/x86/include/asm/pgtable_types.h:485:17: note: in expansion of
macro =E2=80=98pgprot_writethrough=E2=80=99
 extern pgprot_t pgprot_writethrough(pgprot_t prot);
                 ^~~~~~~~~~~~~~~~~~~
./arch/x86/include/asm/pgtable_types.h:492:1: error: unknown type name
=E2=80=98pgprot_t=E2=80=99; did you mean =E2=80=98pgprotval_t=E2=80=99?
 pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 ^~~~~~~~
 pgprotval_t
./arch/x86/include/asm/pgtable_types.h:493:51: error: expected
declaration specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=
=80=99
                               unsigned long size, pgprot_t vma_prot);
                                                   ^~~~~~~~
In file included from ./arch/x86/include/asm/ptrace.h:92:0,
                 from ./arch/x86/include/asm/math_emu.h:5,
                 from ./arch/x86/include/asm/processor.h:12,
                 from ./arch/x86/include/asm/cpufeature.h:5,
                 from ./arch/x86/include/asm/thread_info.h:53,
                 from ./include/linux/thread_info.h:38,
                 from ./arch/x86/include/asm/preempt.h:7,
                 from ./include/linux/preempt.h:81,
                 from ./include/linux/spinlock.h:51,
                 from ./include/linux/mmzone.h:8,
                 from ./include/linux/gfp.h:6,
                 from ./include/linux/slab.h:15,
                 from ./include/linux/crypto.h:24,
                 from arch/x86/kernel/asm-offsets.c:9:
./arch/x86/include/asm/paravirt_types.h:296:25: error: expected
declaration specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=
=80=99
       phys_addr_t phys, pgprot_t flags);
                         ^~~~~~~~
./arch/x86/include/asm/paravirt_types.h:297:1: warning: no semicolon
at end of struct or union
 } __no_randomize_layout;
 ^
In file included from ./arch/x86/include/asm/msr.h:236:0,
                 from ./arch/x86/include/asm/processor.h:21,
                 from ./arch/x86/include/asm/cpufeature.h:5,
                 from ./arch/x86/include/asm/thread_info.h:53,
                 from ./include/linux/thread_info.h:38,
                 from ./arch/x86/include/asm/preempt.h:7,
                 from ./include/linux/preempt.h:81,
                 from ./include/linux/spinlock.h:51,
                 from ./include/linux/mmzone.h:8,
                 from ./include/linux/gfp.h:6,
                 from ./include/linux/slab.h:15,
                 from ./include/linux/crypto.h:24,
                 from arch/x86/kernel/asm-offsets.c:9:
./arch/x86/include/asm/paravirt.h:658:23: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
     phys_addr_t phys, pgprot_t flags)
                       ^~~~~~~~
In file included from ./include/asm-generic/io.h:767:0,
                 from ./arch/x86/include/asm/io.h:401,
                 from ./arch/x86/include/asm/realmode.h:15,
                 from ./arch/x86/include/asm/acpi.h:33,
                 from ./arch/x86/include/asm/fixmap.h:19,
                 from ./arch/x86/include/asm/apic.h:10,
                 from ./arch/x86/include/asm/smp.h:13,
                 from ./arch/x86/include/asm/mmzone_64.h:11,
                 from ./arch/x86/include/asm/mmzone.h:5,
                 from ./include/linux/mmzone.h:912,
                 from ./include/linux/gfp.h:6,
                 from ./include/linux/slab.h:15,
                 from ./include/linux/crypto.h:24,
                 from arch/x86/kernel/asm-offsets.c:9:
./include/linux/vmalloc.h:60:15: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
     int node, pgprot_t prot);
               ^~~~~~~~
./include/linux/vmalloc.h:79:60: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 extern void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot);
                                                            ^~~~~~~~
./include/linux/vmalloc.h:82:4: error: expected declaration specifiers
or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
    pgprot_t prot, unsigned long vm_flags, int node,
    ^~~~~~~~
./include/linux/vmalloc.h:100:25: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
    unsigned long flags, pgprot_t prot);
                         ^~~~~~~~
./include/linux/vmalloc.h:137:48: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
                                                ^~~~~~~~
./include/linux/vmalloc.h:141:9: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
         pgprot_t prot, struct page **pages);
         ^~~~~~~~
In file included from ./arch/x86/include/asm/apic.h:10:0,
                 from ./arch/x86/include/asm/smp.h:13,
                 from ./arch/x86/include/asm/mmzone_64.h:11,
                 from ./arch/x86/include/asm/mmzone.h:5,
                 from ./include/linux/mmzone.h:912,
                 from ./include/linux/gfp.h:6,
                 from ./include/linux/slab.h:15,
                 from ./include/linux/crypto.h:24,
                 from arch/x86/kernel/asm-offsets.c:9:
./arch/x86/include/asm/fixmap.h:151:28: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
          phys_addr_t phys, pgprot_t flags);
                            ^~~~~~~~
In file included from ./arch/x86/include/asm/apic.h:10:0,
                 from ./arch/x86/include/asm/smp.h:13,
                 from ./arch/x86/include/asm/mmzone_64.h:11,
                 from ./arch/x86/include/asm/mmzone.h:5,
                 from ./include/linux/mmzone.h:912,
                 from ./include/linux/gfp.h:6,
                 from ./include/linux/slab.h:15,
                 from ./include/linux/crypto.h:24,
                 from arch/x86/kernel/asm-offsets.c:9:
./arch/x86/include/asm/fixmap.h:187:22: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
    phys_addr_t phys, pgprot_t flags);
                      ^~~~~~~~
In file included from ./include/linux/kasan.h:17:0,
                 from ./include/linux/slab.h:129,
                 from ./include/linux/crypto.h:24,
                 from arch/x86/kernel/asm-offsets.c:9:
./arch/x86/include/asm/pgtable.h:519:42: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 static inline pgprotval_t massage_pgprot(pgprot_t pgprot)
                                          ^~~~~~~~
./arch/x86/include/asm/pgtable.h:529:52: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 static inline pte_t pfn_pte(unsigned long page_nr, pgprot_t pgprot)
                                                    ^~~~~~~~
./arch/x86/include/asm/pgtable.h:535:52: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
                                                    ^~~~~~~~
./arch/x86/include/asm/pgtable.h:541:52: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 static inline pud_t pfn_pud(unsigned long page_nr, pgprot_t pgprot)
                                                    ^~~~~~~~
./arch/x86/include/asm/pgtable.h:547:43: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
                                           ^~~~~~~~
./arch/x86/include/asm/pgtable.h:561:43: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
                                           ^~~~~~~~
./arch/x86/include/asm/pgtable.h:572:23: error: expected =E2=80=98=3D=E2=80=
=99, =E2=80=98,=E2=80=99,
=E2=80=98;=E2=80=99, =E2=80=98asm=E2=80=99 or =E2=80=98__attribute__=E2=80=
=99 before =E2=80=98pgprot_modify=E2=80=99
 #define pgprot_modify pgprot_modify
                       ^
./arch/x86/include/asm/pgtable.h:573:24: note: in expansion of macro
=E2=80=98pgprot_modify=E2=80=99
 static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
                        ^~~~~~~~~~~~~
In file included from ./arch/x86/include/asm/pgtable.h:630:0,
                 from ./include/linux/kasan.h:17,
                 from ./include/linux/slab.h:129,
                 from ./include/linux/crypto.h:24,
                 from arch/x86/kernel/asm-offsets.c:9:
./include/linux/mm_types.h:297:2: error: expected
specifier-qualifier-list before =E2=80=98pgprot_t=E2=80=99
  pgprot_t vm_page_prot;  /* Access permissions of this VMA. */
  ^~~~~~~~
In file included from ./arch/x86/include/asm/pgtable.h:1292:0,
                 from ./include/linux/kasan.h:17,
                 from ./include/linux/slab.h:129,
                 from ./include/linux/crypto.h:24,
                 from arch/x86/kernel/asm-offsets.c:9:
./include/asm-generic/pgtable.h:773:56: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 extern int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
                                                        ^~~~~~~~
./include/asm-generic/pgtable.h:776:58: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 extern void track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
                                                          ^~~~~~~~
./include/asm-generic/pgtable.h:972:62: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 static inline int p4d_set_huge(p4d_t *p4d, phys_addr_t addr, pgprot_t prot=
)
                                                              ^~~~~~~~
./include/asm-generic/pgtable.h:982:48: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot);
                                                ^~~~~~~~
./include/asm-generic/pgtable.h:983:48: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot);
                                                ^~~~~~~~
./include/asm-generic/pgtable.h:1034:24: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
    unsigned long size, pgprot_t *vma_prot);
                        ^~~~~~~~
In file included from ./include/linux/irq.h:25:0,
                 from ./arch/x86/include/asm/hardirq.h:6,
                 from ./include/linux/hardirq.h:9,
                 from arch/x86/kernel/asm-offsets.c:12:
./include/linux/io.h:37:33: error: expected declaration specifiers or
=E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
          phys_addr_t phys_addr, pgprot_t prot);
                                 ^~~~~~~~
In file included from ./include/linux/cgroup.h:17:0,
                 from ./include/linux/memcontrol.h:22,
                 from ./include/linux/swap.h:9,
                 from ./include/linux/suspend.h:5,
                 from arch/x86/kernel/asm-offsets.c:13:
./include/linux/fs.h: In function =E2=80=98vma_is_dax=E2=80=99:
./include/linux/fs.h:3200:12: error: =E2=80=98struct vm_area_struct=E2=80=
=99 has no
member named =E2=80=98vm_file=E2=80=99
  return vma->vm_file && IS_DAX(vma->vm_file->f_mapping->host);
            ^~
In file included from ./include/linux/cgroup.h:17:0,
                 from ./include/linux/memcontrol.h:22,
                 from ./include/linux/swap.h:9,
                 from ./include/linux/suspend.h:5,
                 from arch/x86/kernel/asm-offsets.c:13:
./include/linux/fs.h:3200:35: error: =E2=80=98struct vm_area_struct=E2=80=
=99 has no
member named =E2=80=98vm_file=E2=80=99
  return vma->vm_file && IS_DAX(vma->vm_file->f_mapping->host);
                                   ^
./include/linux/fs.h:1901:26: note: in definition of macro =E2=80=98IS_DAX=
=E2=80=99
 #define IS_DAX(inode)  ((inode)->i_flags & S_DAX)
                          ^~~~~
In file included from ./include/linux/cgroup.h:17:0,
                 from ./include/linux/memcontrol.h:22,
                 from ./include/linux/swap.h:9,
                 from ./include/linux/suspend.h:5,
                 from arch/x86/kernel/asm-offsets.c:13:
./include/linux/fs.h: In function =E2=80=98vma_is_fsdax=E2=80=99:
./include/linux/fs.h:3207:10: error: =E2=80=98struct vm_area_struct=E2=80=
=99 has no
member named =E2=80=98vm_file=E2=80=99
  if (!vma->vm_file)
          ^~
./include/linux/fs.h:3211:24: error: =E2=80=98struct vm_area_struct=E2=80=
=99 has no
member named =E2=80=98vm_file=E2=80=99
  inode =3D file_inode(vma->vm_file);
                        ^~
In file included from ./include/linux/memcontrol.h:29:0,
                 from ./include/linux/swap.h:9,
                 from ./include/linux/suspend.h:5,
                 from arch/x86/kernel/asm-offsets.c:13:
./include/linux/mm.h: At top level:
./include/linux/mm.h:294:17: error: expected =E2=80=98=3D=E2=80=99, =E2=80=
=98,=E2=80=99, =E2=80=98;=E2=80=99, =E2=80=98asm=E2=80=99 or
=E2=80=98__attribute__=E2=80=99 before =E2=80=98protection_map=E2=80=99
 extern pgprot_t protection_map[16];
                 ^~~~~~~~~~~~~~
In file included from ./include/linux/mm.h:463:0,
                 from ./include/linux/memcontrol.h:29,
                 from ./include/linux/swap.h:9,
                 from ./include/linux/suspend.h:5,
                 from arch/x86/kernel/asm-offsets.c:13:
./include/linux/huge_mm.h:47:24: error: expected declaration
specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
    unsigned long addr, pgprot_t newprot,
                        ^~~~~~~~
./include/linux/huge_mm.h: In function =E2=80=98transparent_hugepage_enable=
d=E2=80=99:
./include/linux/huge_mm.h:97:11: error: =E2=80=98struct vm_area_struct=E2=
=80=99 has no
member named =E2=80=98vm_flags=E2=80=99; did you mean =E2=80=98vm_start=E2=
=80=99?
  if (vma->vm_flags & VM_NOHUGEPAGE)
           ^~~~~~~~
           vm_start
./include/linux/huge_mm.h:114:18: error: =E2=80=98struct vm_area_struct=E2=
=80=99 has
no member named =E2=80=98vm_flags=E2=80=99; did you mean =E2=80=98vm_start=
=E2=80=99?
   return !!(vma->vm_flags & VM_HUGEPAGE);
                  ^~~~~~~~
                  vm_start
In file included from ./arch/x86/include/asm/atomic.h:5:0,
                 from ./include/linux/atomic.h:5,
                 from ./include/linux/crypto.h:20,
                 from arch/x86/kernel/asm-offsets.c:9:
./include/linux/mm.h: In function =E2=80=98maybe_mkwrite=E2=80=99:
./include/linux/mm.h:683:18: error: =E2=80=98struct vm_area_struct=E2=80=99=
 has no
member named =E2=80=98vm_flags=E2=80=99; did you mean =E2=80=98vm_start=E2=
=80=99?
  if (likely(vma->vm_flags & VM_WRITE))
                  ^
./include/linux/compiler.h:76:40: note: in definition of macro =E2=80=98lik=
ely=E2=80=99
 # define likely(x) __builtin_expect(!!(x), 1)
                                        ^
In file included from ./include/linux/memcontrol.h:29:0,
                 from ./include/linux/swap.h:9,
                 from ./include/linux/suspend.h:5,
                 from arch/x86/kernel/asm-offsets.c:13:
./include/linux/mm.h: In function =E2=80=98vma_is_anonymous=E2=80=99:
./include/linux/mm.h:1479:15: error: =E2=80=98struct vm_area_struct=E2=80=
=99 has no
member named =E2=80=98vm_ops=E2=80=99; did you mean =E2=80=98vm_end=E2=80=
=99?
  return !vma->vm_ops;
               ^~~~~~
               vm_end
./include/linux/mm.h: At top level:
./include/linux/mm.h:1499:29: error: expected declaration specifiers
or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
          unsigned long end, pgprot_t newprot,
                             ^~~~~~~~
./include/linux/mm.h:1618:55: error: expected declaration specifiers
or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
 int vma_wants_writenotify(struct vm_area_struct *vma, pgprot_t vm_page_pro=
t);
                                                       ^~~~~~~~
In file included from ./include/linux/memcontrol.h:29:0,
                 from ./include/linux/swap.h:9,
                 from ./include/linux/suspend.h:5,
                 from arch/x86/kernel/asm-offsets.c:13:
./include/linux/mm.h: In function =E2=80=98vm_start_gap=E2=80=99:
./include/linux/mm.h:2347:11: error: =E2=80=98struct vm_area_struct=E2=80=
=99 has no
member named =E2=80=98vm_flags=E2=80=99; did you mean =E2=80=98vm_start=E2=
=80=99?
  if (vma->vm_flags & VM_GROWSDOWN) {
           ^~~~~~~~
           vm_start
./include/linux/mm.h: In function =E2=80=98vm_end_gap=E2=80=99:
./include/linux/mm.h:2359:11: error: =E2=80=98struct vm_area_struct=E2=80=
=99 has no
member named =E2=80=98vm_flags=E2=80=99; did you mean =E2=80=98vm_start=E2=
=80=99?
  if (vma->vm_flags & VM_GROWSUP) {
           ^~~~~~~~
           vm_start
./include/linux/mm.h: At top level:
./include/linux/mm.h:2385:1: error: unknown type name =E2=80=98pgprot_t=E2=
=80=99; did
you mean =E2=80=98pgprotval_t=E2=80=99?
 pgprot_t vm_get_page_prot(unsigned long vm_flags);
 ^~~~~~~~
 pgprotval_t
./include/linux/mm.h:2405:43: error: expected declaration specifiers
or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
    unsigned long pfn, unsigned long size, pgprot_t);
                                           ^~~~~~~~
./include/linux/mm.h:2410:23: error: expected declaration specifiers
or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=80=99
    unsigned long pfn, pgprot_t pgprot);
                       ^~~~~~~~
In file included from ./arch/x86/include/asm/desc.h:10:0,
                 from ./arch/x86/include/asm/suspend_64.h:10,
                 from ./arch/x86/include/asm/suspend.h:5,
                 from arch/x86/kernel/asm-offsets.c:19:
./arch/x86/include/asm/cpu_entry_area.h:8:1: error: version control
conflict marker in file
 <<<<<<< HEAD
 ^~~~~~~
In file included from ./arch/x86/include/asm/cpu_entry_area.h:10:0,
                 from ./arch/x86/include/asm/desc.h:10,
                 from ./arch/x86/include/asm/suspend_64.h:10,
                 from ./arch/x86/include/asm/suspend.h:5,
                 from arch/x86/kernel/asm-offsets.c:19:
./arch/x86/include/asm/intel_ds.h:27:1: warning: empty declaration
 } __aligned(PAGE_SIZE);
 ^
In file included from ./arch/x86/include/asm/desc.h:10:0,
                 from ./arch/x86/include/asm/suspend_64.h:10,
                 from ./arch/x86/include/asm/suspend.h:5,
                 from arch/x86/kernel/asm-offsets.c:19:
./arch/x86/include/asm/cpu_entry_area.h:11:1: error: version control
conflict marker in file
 >>>>>>> linux-next/akpm-base
 ^~~~~~~
./arch/x86/include/asm/cpu_entry_area.h:70:58: error: expected
declaration specifiers or =E2=80=98...=E2=80=99 before =E2=80=98pgprot_t=E2=
=80=99
 extern void cea_set_pte(void *cea_vaddr, phys_addr_t pa, pgprot_t flags);
                                                          ^~~~~~~~
./arch/x86/include/asm/cpu_entry_area.h: In function =E2=80=98cpu_entry_sta=
ck=E2=80=99:
./arch/x86/include/asm/cpu_entry_area.h:84:33: error: dereferencing
pointer to incomplete type =E2=80=98struct cpu_entry_area=E2=80=99
  return &get_cpu_entry_area(cpu)->entry_stack_page.stack;
                                 ^~
In file included from arch/x86/kernel/asm-offsets.c:20:0:
./arch/x86/include/asm/tlbflush.h: At top level:
./arch/x86/include/asm/tlbflush.h:13:1: error: version control
conflict marker in file
 <<<<<<< HEAD
 ^~~~~~~
./arch/x86/include/asm/tlbflush.h:28:1: error: version control
conflict marker in file
 =3D=3D=3D=3D=3D=3D=3D
 ^~~~~~~
In file included from arch/x86/kernel/asm-offsets.c:20:0:
./arch/x86/include/asm/tlbflush.h:63:1: error: version control
conflict marker in file
 >>>>>>> linux-next/akpm-base
 ^~~~~~~
./arch/x86/include/asm/tlbflush.h:92:1: warning: "/*" within comment [-Wcom=
ment]
 /*

./arch/x86/include/asm/tlbflush.h:97:0: warning: "MAX_ASID_AVAILABLE" redef=
ined
 #define MAX_ASID_AVAILABLE ((1 << CR3_AVAIL_PCID_BITS) - 2)

./arch/x86/include/asm/tlbflush.h:77:0: note: this is the location of
the previous definition
 #define MAX_ASID_AVAILABLE ((1 << CR3_AVAIL_ASID_BITS) - 2)

cc1: some warnings being treated as errors
Kbuild:56: recipe for target 'arch/x86/kernel/asm-offsets.s' failed
make[1]: *** [arch/x86/kernel/asm-offsets.s] Error 1
Makefile:1090: recipe for target 'prepare0' failed
make: *** [prepare0] Error 2


> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report.
> If you forgot to add the Reported-by tag, once the fix for this bug is
> merged
> into any tree, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
> Note: all commands must start from beginning of the line in the email bod=
y.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/94eb2c07793623fa00056161=
8401%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
