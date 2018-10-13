Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68A876B0003
	for <linux-mm@kvack.org>; Sat, 13 Oct 2018 05:32:14 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id 203-v6so9323552wmv.1
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 02:32:14 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.15.3])
        by mx.google.com with ESMTPS id t142-v6si3049140wmd.74.2018.10.13.02.32.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Oct 2018 02:32:12 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] treewide: remove unused address argument from
 pte_alloc functions
References: <20181012013756.11285-1-joel@joelfernandes.org>
 <03b524f3-5f3a-baa0-2254-9c588103d2d6@users.sourceforge.net>
 <20181012194210.GA27630@joelaf.mtv.corp.google.com>
From: SF Markus Elfring <elfring@users.sourceforge.net>
Message-ID: <e1be1dda-90ab-052d-496b-3de01ffc80d1@users.sourceforge.net>
Date: Sat, 13 Oct 2018 11:22:49 +0200
MIME-Version: 1.0
In-Reply-To: <20181012194210.GA27630@joelaf.mtv.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com, Michal Hocko <mhocko@kernel.org>, Julia Lawall <Julia.Lawall@lip6.fr>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Daniel Colascione <dancol@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Helge Deller <deller@gmx.de>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "James E. J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jonas Bonn <jonas@southpole.se>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ley Foon Tan <lftan@altera.com>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, pantin@google.com, Lokesh Gidra <lokeshgidra@google.com>, Max Filippov <jcmvbkbc@gmail.com>, Minchan Kim <minchan@kernel.org>, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Sam Creasey <sammy@sammy.net>, sparclinux@vger.kernel.org, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>

>>> The changes were obtained by applying the following Coccinelle script.

How do you think about to adjust the order of provided information
in the commit description?
1. Update goals
2. Transformation implementation at the end


>> "^(?:pte_alloc(?:_one(?:_kernel)?)?|__pte_alloc(?:_kernel)?)$";
> 
> Sure it looks more clever, but why?

1. Usage of non-capturing parentheses
2. Clearer specification which parts can be treated as optional
   in the search pattern.


> Ugh that's harder to read and confusing.

* Do you care for coding style and execution speed of regular expressions?

* If you would prefer to list function names without placeholders,
  you can eventually specify them also within SmPL disjunctions directly.

* It can look simpler to use an identifier list as a constraint variant.
  http://coccinelle.lip6.fr/docs/main_grammar002.html


> Again this is confusing.

The view points can be different for such SmPL code.

 T3 fn(T1 E1
(
-           , T2 E2
|           , T2 E2
-           , T4 E4
)     );


> It makes one think that maybe the second argument can also be removed

You expressed this as the first transformation possibility, didn't you?

You would like to delete an argument from the end of a function
or macro parameter (or expression) list.
I suggest then again to avoid the SmPL specification of source code additions
(plus lines in the file difference format).


> and requires careful observation that the ");" follows.

Yes, of course.

Would you care more in the distinction which code parts should be kept unchanged?


> Right, I don't need it in this case.

Thanks for your understanding that the metavariable a??position pa??
can be deleted in the SmPL rule a??pte_alloc_macroa??.


> But the script works either way.

I imagine that you can become interested in a bit nicer run time characteristics.


> I like to take more of a problem solving approach that makes sense,

This is usual.


> than aiming for perfection,

If you will work more with scripts for the semantic patch language,
you might become used to additional coding variants.


> after all this is a useful script that we do not need to check
> in once we finish with it.

I am curious if there will evolve a need to add similar transformation approaches
to a known script collection.
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/scripts/coccinelle?id=79fc170b1f5c36f486d886bfbd59eb4e62321128

Would you eventually like to run such scripts once more?

Regards,
Markus
