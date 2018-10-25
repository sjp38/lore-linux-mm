Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE816B0289
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 06:47:10 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v88-v6so6188919pfk.19
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 03:47:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bj11-v6sor6148749plb.16.2018.10.25.03.47.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 03:47:08 -0700 (PDT)
Date: Thu, 25 Oct 2018 13:47:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/4] treewide: remove unused address argument from
 pte_alloc functions (v2)
Message-ID: <20181025104703.esl6wxyg2ihe4zoc@kshutemo-mobl1>
References: <20181013013200.206928-1-joel@joelfernandes.org>
 <20181013013200.206928-2-joel@joelfernandes.org>
 <20181024083716.GN3109@worktop.c.hoisthospitality.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181024083716.GN3109@worktop.c.hoisthospitality.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>, linux-kernel@vger.kernel.org, kernel-team@android.com, Michal Hocko <mhocko@kernel.org>, Julia Lawall <Julia.Lawall@lip6.fr>, akpm@linux-foundation.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, anton.ivanov@kot-begemot.co.uk, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, dancol@google.com, Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, elfring@users.sourceforge.net, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Helge Deller <deller@gmx.de>, hughd@google.com, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jonas Bonn <jonas@southpole.se>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ley Foon Tan <lftan@altera.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, lokeshgidra@google.com, Max Filippov <jcmvbkbc@gmail.com>, minchan@kernel.org, nios2-dev@lists.rocketboards.org, pantin@google.com, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Sam Creasey <sammy@sammy.net>, sparclinux@vger.kernel.org, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>

On Wed, Oct 24, 2018 at 10:37:16AM +0200, Peter Zijlstra wrote:
> On Fri, Oct 12, 2018 at 06:31:57PM -0700, Joel Fernandes (Google) wrote:
> > This series speeds up mremap(2) syscall by copying page tables at the
> > PMD level even for non-THP systems. There is concern that the extra
> > 'address' argument that mremap passes to pte_alloc may do something
> > subtle architecture related in the future that may make the scheme not
> > work.  Also we find that there is no point in passing the 'address' to
> > pte_alloc since its unused. So this patch therefore removes this
> > argument tree-wide resulting in a nice negative diff as well. Also
> > ensuring along the way that the enabled architectures do not do anything
> > funky with 'address' argument that goes unnoticed by the optimization.
> 
> Did you happen to look at the history of where that address argument
> came from? -- just being curious here. ISTR something vague about
> architectures having different paging structure for different memory
> ranges.

I see some archicetures (i.e. sparc and, I believe power) used the address
for coloring. It's not needed anymore. Page allocator and SL?B are good
enough now.

See 3c936465249f ("[SPARC64]: Kill pgtable quicklists and use SLAB.")

-- 
 Kirill A. Shutemov
