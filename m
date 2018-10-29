Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 143DA6B036B
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 06:28:36 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id w124-v6so2306822oiw.15
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 03:28:36 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y203-v6si9256156oie.8.2018.10.29.03.28.34
        for <linux-mm@kvack.org>;
        Mon, 29 Oct 2018 03:28:34 -0700 (PDT)
Date: Mon, 29 Oct 2018 10:28:40 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/4] mm: speed up mremap by 500x on large regions (v2)
Message-ID: <20181029102840.GC13965@arm.com>
References: <20181013013200.206928-1-joel@joelfernandes.org>
 <20181013013200.206928-3-joel@joelfernandes.org>
 <20181024101255.it4lptrjogalxbey@kshutemo-mobl1>
 <20181024115733.GN8537@350D>
 <20181024125724.yf6frdimjulf35do@kshutemo-mobl1>
 <20181025020907.GA13560@joelaf.mtv.corp.google.com>
 <20181025101900.phqnqpoju5t2gar5@kshutemo-mobl1>
 <20181026211148.GA140716@joelaf.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181026211148.GA140716@joelaf.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, kernel-team@android.com, minchan@kernel.org, pantin@google.com, hughd@google.com, lokeshgidra@google.com, dancol@google.com, mhocko@kernel.org, akpm@linux-foundation.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, anton.ivanov@kot-begemot.co.uk, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, elfring@users.sourceforge.net, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jonas Bonn <jonas@southpole.se>, Julia Lawall <Julia.Lawall@lip6.fr>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ley Foon Tan <lftan@altera.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, Max Filippov <jcmvbkbc@gmail.com>, nios2-dev@lists.rocketboards.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Sam Creasey <sammy@sammy.net>, sparclinux@vger.kernel.org, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>

On Fri, Oct 26, 2018 at 02:11:48PM -0700, Joel Fernandes wrote:
> My thinking is to take it slow and get the patch in in its current state,
> since it improves x86. Then as a next step, look into why the arm64 tlb
> flushes are that expensive and look into optimizing that. On arm64 I am
> testing on a 4.9 kernel so I'm wondering there are any optimizations since
> 4.9 that can help speed it up there. After that, if all else fails about
> speeding up arm64, then I look into developing the cleanest possible solution
> where we can keep the lock held for longer and flush lesser.

We rewrote a good chunk of the arm64 TLB invalidation and core mmu_gather
code this merge window, so please do have another look at -rc1!

Will
