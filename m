Content-Class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [patch] removes MAX_ARG_PAGES
Date: Mon, 7 May 2007 10:46:49 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A01719390@scsmsx411.amr.corp.intel.com>
In-Reply-To: <65dd6fd50705060151m78bb9b4fpcb941b16a8c4709e@mail.gmail.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ollie Wild <aaw@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

> We've tested the following architectures: i386, x86_64, um/i386,
> parisc, and frv.  These are representative of the various scenarios
> which this patch addresses, but other architecture teams should try it
> out to make sure there aren't any unexpected gotchas.

Doesn't build on ia64: complaints from arch/ia64/ia32/binfmt_elf.c
(which #includes ../../../fs/binfmt_elf.c) ...

arch/ia64/ia32/binfmt_elf32.c: In function `ia32_setup_arg_pages':
arch/ia64/ia32/binfmt_elf32.c:206: error: `MAX_ARG_PAGES' undeclared (first use in this function)
arch/ia64/ia32/binfmt_elf32.c:206: error: (Each undeclared identifier is reported only once
arch/ia64/ia32/binfmt_elf32.c:206: error: for each function it appears in.)
arch/ia64/ia32/binfmt_elf32.c:240: error: structure has no member named `page'
arch/ia64/ia32/binfmt_elf32.c:242: error: structure has no member named `page'
arch/ia64/ia32/binfmt_elf32.c:243: warning: implicit declaration of function `install_arg_page'
make[1]: *** [arch/ia64/ia32/binfmt_elf32.o] Error 1

Turning off CONFIG_IA32-SUPPORT, the kernel built, but oops'd during boot.
My serial connection to my test machine is currently broken, so I didn't
get a capture of the stack trace, sorry.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
