Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 205AE6B0003
	for <linux-mm@kvack.org>; Sat,  3 Nov 2018 09:01:03 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id 88-v6so3646501wrp.21
        for <linux-mm@kvack.org>; Sat, 03 Nov 2018 06:01:03 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.17.11])
        by mx.google.com with ESMTPS id b9-v6si25570482wrw.102.2018.11.03.06.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Nov 2018 06:01:01 -0700 (PDT)
Subject: Re: [PATCH -next v2 1/3] mm: treewide: remove unused address argument
 from pte_alloc functions
References: <20181103040041.7085-1-joelaf@google.com>
 <20181103040041.7085-2-joelaf@google.com>
From: SF Markus Elfring <elfring@users.sourceforge.net>
Message-ID: <fd939e7c-3d9e-760e-f20c-e7263f064153@users.sourceforge.net>
Date: Sat, 3 Nov 2018 13:51:20 +0100
MIME-Version: 1.0
In-Reply-To: <20181103040041.7085-2-joelaf@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>, kernel-janitors@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Julia Lawall <Julia.Lawall@lip6.fr>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Anton Ivanov <anton.ivanov@kot-begemot.co.uk>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Daniel Colascione <dancol@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Helge Deller <deller@gmx.de>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "James E. J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jonas Bonn <jonas@southpole.se>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ley Foon Tan <lftan@altera.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, Lokesh Gidra <lokeshgidra@google.com>, Max Filippov <jcmvbkbc@gmail.com>, Minchan Kim <minchan@kernel.org>, nios2-dev@lists.rocketboards.org, pantin@google.com, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Sam Creasey <sammy@sammy.net>, sparclinux@vger.kernel.org, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>

> a?| There is concern that a?|

Does this wording need a small adjustment?


> The changes were obtained by applying the following Coccinelle script.

I would find it nicer if previous patch review comments will trigger
further useful effects here.
https://patchwork.kernel.org/patch/10637703/#22265203
https://lore.kernel.org/linuxppc-dev/03b524f3-5f3a-baa0-2254-9c588103d2d6@users.sourceforge.net/
https://www.mail-archive.com/linuxppc-dev@lists.ozlabs.org/msg140009.html


If you have got difficulties with the usage of advanced regular expressions
for SmPL constraints, I suggest to use desired function names in SmPL lists
or disjunctions instead because of different run time characteristics
for such a source code transformation approach.


> // Note: I split the 'identifier fn' line, so if you are manually
> // running it, please unsplit it so it runs for you.

Please delete this questionable comment.

* The semantic patch language should handle the mentioned code formatting.
* You can use multi-line regular expressions (if it would be desired).


> @pte_alloc_func_def depends on patch exists@
> identifier E2;
> identifier fn =~

How do you think about to avoid the repetition of a SmPL key word at such places?

Regards,
Markus
