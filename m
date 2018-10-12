Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C57206B000D
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 12:46:48 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h76-v6so11986726pfd.10
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 09:46:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a33-v6sor1680328pgl.83.2018.10.12.09.46.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 09:46:47 -0700 (PDT)
Date: Fri, 12 Oct 2018 09:46:44 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v2 1/2] treewide: remove unused address argument from
 pte_alloc functions
Message-ID: <20181012164644.GC223066@joelaf.mtv.corp.google.com>
References: <20181012013756.11285-1-joel@joelfernandes.org>
 <594fc952-5e87-3162-b2f9-963479d16eb3@kot-begemot.co.uk>
 <20181012163433.GA223066@joelaf.mtv.corp.google.com>
 <alpine.DEB.2.20.1810121838180.4366@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1810121838180.4366@hadrien>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, lokeshgidra@google.com, linux-riscv@lists.infradead.org, elfring@users.sourceforge.net, Jonas Bonn <jonas@southpole.se>, linux-s390@vger.kernel.org, dancol@google.com, Yoshinori Sato <ysato@users.sourceforge.jp>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-hexagon@vger.kernel.org, Helge Deller <deller@gmx.de>, "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, hughd@google.com, "James E.J. Bottomley" <jejb@parisc-linux.org>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-snps-arc@lists.infradead.org, kernel-team@android.com, Sam Creasey <sammy@sammy.net>, Fenghua Yu <fenghua.yu@intel.com>, Jeff Dike <jdike@addtoit.com>, linux-um@lists.infradead.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, linux-m68k@vger.kernel.org, openrisc@lists.librecores.org, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, nios2-dev@lists.rocketboards.org, kirill@shutemov.name, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, Richard Weinberger <richard@nod.at>, linux-parisc@vger.kernel.org, pantin@google.com, Max Filippov <jcmvbkbc@gmail.com>, minchan@kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-alpha@vger.kernel.org, Ley Foon Tan <lftan@altera.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Fri, Oct 12, 2018 at 06:38:57PM +0200, Julia Lawall wrote:
> > I wrote something like this as below but it failed to compile, Julia any
> > suggestions on how to express this?
> >
> > @pte_alloc_func_proto depends on patch exists@
> > type T1, T2, T3, T4;
> > identifier fn =~
> > "^(__pte_alloc|pte_alloc_one|pte_alloc|__pte_alloc_kernel|pte_alloc_one_kernel)$";
> > @@
> >
> > (
> > - T3 fn(T1, T2);
> > + T3 fn(T1);
> > |
> > - T3 fn(T1, T2, T4);
> > + T3 fn(T1, T2);
> > )
> 
> What goes wrong?  It seems fine to me.

Weird it seems working now. I could swear 5 minutes ago it wasn't and I did
give a unique rule name. Don't know what I missed.

Anyway, thank you for all the quick responses and the help!

- Joel
