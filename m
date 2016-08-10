Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 68AB46B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 00:36:55 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so56029264pab.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 21:36:55 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id z88si46361680pff.218.2016.08.09.21.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 21:36:54 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v3] powerpc: Do not make the entire heap executable
In-Reply-To: <20160809190822.28856-1-dvlasenk@redhat.com>
References: <20160809190822.28856-1-dvlasenk@redhat.com>
Date: Wed, 10 Aug 2016 14:36:51 +1000
Message-ID: <87lh05tf30.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <dvlasenk@redhat.com>, linuxppc-dev@lists.ozlabs.org
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Kees Cook <keescook@chromium.org>, Oleg Nesterov <oleg@redhat.com>, Florian Weimer <fweimer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Denys Vlasenko <dvlasenk@redhat.com> writes:

> On 32-bit powerps the ELF PLT sections of binaries (built with --bss-plt,
> or with a toolchain which defaults to it) look like this:
...
>
>  arch/powerpc/include/asm/page.h    | 10 +---------
>  arch/powerpc/include/asm/page_32.h |  2 --
>  arch/powerpc/include/asm/page_64.h |  4 ----
>  fs/binfmt_elf.c                    | 34 ++++++++++++++++++++++++++--------
>  include/linux/mm.h                 |  1 +
>  mm/mmap.c                          | 20 +++++++++++++++-----
>  6 files changed, 43 insertions(+), 28 deletions(-)

What tree is this against?

I can't get it to apply to either Linus' tree or linux-next.

cheers

$ patch --dry-run -p1 < diff.diff
checking file arch/powerpc/include/asm/page.h
checking file arch/powerpc/include/asm/page_32.h
checking file arch/powerpc/include/asm/page_64.h
checking file fs/binfmt_elf.c
Hunk #3 FAILED at 613.
Hunk #4 FAILED at 633.
Hunk #5 succeeded at 681 (offset 2 lines).
Hunk #6 succeeded at 889 (offset 2 lines).
Hunk #7 succeeded at 984 (offset 2 lines).
Hunk #8 succeeded at 1003 (offset 2 lines).
2 out of 8 hunks FAILED
checking file include/linux/mm.h
checking file mm/mmap.c
Hunk #1 FAILED at 2653.
Hunk #2 succeeded at 2668 (offset 2 lines).
Hunk #3 succeeded at 2736 (offset 2 lines).
Hunk #4 succeeded at 2750 (offset 2 lines).
1 out of 4 hunks FAILED

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
