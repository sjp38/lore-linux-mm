Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E28F56B025F
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 04:15:16 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id h16so1288340wrf.0
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 01:15:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor59013wmw.52.2017.09.28.01.15.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 01:15:15 -0700 (PDT)
Date: Thu, 28 Sep 2017 10:15:12 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 03/19] x86/kasan: Use the same shadow offset for 4- and
 5-level paging
Message-ID: <20170928081512.3zakiygb3uknbtr3@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-4-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-4-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> We are going to support boot-time switching between 4- and 5-level
> paging. For KASAN it means we cannot have different KASAN_SHADOW_OFFSET
> for different paging modes: the constant is passed to gcc to generate
> code and cannot be changed at runtime.
> 
> This patch changes KASAN code to use 0xdffffc0000000000 as shadow offset
> for both 4- and 5-level paging.
> 
> For 5-level paging it means that shadow memory region is not aligned to
> PGD boundary anymore and we have to handle unaligned parts of the region
> properly.
> 
> In addition, we have to exclude paravirt code from KASAN instrumentation
> as we now use set_pgd() before KASAN is fully ready.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> [kirill.shutemov@linux.intel.com: clenaup, changelog message]
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Bad SOB chain. If Andrey the true author of this patch then it be reflected in a 
"From:" line.

> ---
>  arch/x86/Kconfig            |  1 -
>  arch/x86/kernel/Makefile    |  3 +-
>  arch/x86/mm/kasan_init_64.c | 86 ++++++++++++++++++++++++++++++++++-----------
>  3 files changed, 67 insertions(+), 23 deletions(-)

This is a lot of complex code added with exactly zero lines of comments that 
explains all the complexity ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
