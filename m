Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 368A86B0269
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 12:37:29 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b95-v6so9533390plb.10
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 09:37:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w19-v6sor1511415plp.9.2018.10.12.09.37.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 09:37:28 -0700 (PDT)
Date: Fri, 12 Oct 2018 09:37:25 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v2 1/2] treewide: remove unused address argument from
 pte_alloc functions
Message-ID: <20181012163725.GB223066@joelaf.mtv.corp.google.com>
References: <20181012013756.11285-1-joel@joelfernandes.org>
 <20181012110906.fpfttp4nhvsr2ps7@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181012110906.fpfttp4nhvsr2ps7@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com, Michal Hocko <mhocko@kernel.org>, Julia Lawall <Julia.Lawall@lip6.fr>, elfring@users.sourceforge.net, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, dancol@google.com, Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Helge Deller <deller@gmx.de>, hughd@google.com, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jonas Bonn <jonas@southpole.se>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ley Foon Tan <lftan@altera.com>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, pantin@google.com, lokeshgidra@google.com, Max Filippov <jcmvbkbc@gmail.com>, minchan@kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Sam Creasey <sammy@sammy.net>, sparclinux@vger.kernel.org, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, akpm@linux-foundation.org

On Fri, Oct 12, 2018 at 02:09:06PM +0300, Kirill A. Shutemov wrote:
> On Thu, Oct 11, 2018 at 06:37:55PM -0700, Joel Fernandes (Google) wrote:
> > diff --git a/arch/m68k/include/asm/mcf_pgalloc.h b/arch/m68k/include/asm/mcf_pgalloc.h
> > index 12fe700632f4..4399d712f6db 100644
> > --- a/arch/m68k/include/asm/mcf_pgalloc.h
> > +++ b/arch/m68k/include/asm/mcf_pgalloc.h
> > @@ -12,8 +12,7 @@ extern inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
> >  
> >  extern const char bad_pmd_string[];
> >  
> > -extern inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
> > -	unsigned long address)
> > +extern inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
> >  {
> >  	unsigned long page = __get_free_page(GFP_DMA);
> >  
> > @@ -32,8 +31,6 @@ extern inline pmd_t *pmd_alloc_kernel(pgd_t *pgd, unsigned long address)
> >  #define pmd_alloc_one_fast(mm, address) ({ BUG(); ((pmd_t *)1); })
> >  #define pmd_alloc_one(mm, address)      ({ BUG(); ((pmd_t *)2); })
> >  
> > -#define pte_alloc_one_fast(mm, addr) pte_alloc_one(mm, addr)
> > -
> 
> I believe this was one done manually, right?
> Please explicitely state everthing you did on not of sematic patch

Ok, I can update the changelog with that information next time I send it.
This is the only thing I didn't mention in the changelog since it was a
trivial unused function deletion.. but I mentioned everything else..

And sir, you are one thorough reviewer! ;-)

 - Joel

[..]
