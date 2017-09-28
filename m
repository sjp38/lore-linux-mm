Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30CC16B025F
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 04:19:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m127so1459877wmm.3
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 01:19:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v67sor67020wma.13.2017.09.28.01.19.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 01:19:42 -0700 (PDT)
Date: Thu, 28 Sep 2017 10:19:39 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 07/19] x86/mm: Make virtual memory layout movable for
 CONFIG_X86_5LEVEL
Message-ID: <20170928081939.nvrf25spnzgtyckz@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-8-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-8-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> We need to be able to adjust virtual memory layout at runtime to be able
> to switch between 4- and 5-level paging at boot-time.
> 
> KASLR already has movable __VMALLOC_BASE, __VMEMMAP_BASE and __PAGE_OFFSET.
> Let's re-use it.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/include/asm/kaslr.h            | 4 ----
>  arch/x86/include/asm/page_64.h          | 4 ++++
>  arch/x86/include/asm/page_64_types.h    | 2 +-
>  arch/x86/include/asm/pgtable_64_types.h | 2 +-
>  arch/x86/kernel/head64.c                | 9 +++++++++
>  arch/x86/mm/kaslr.c                     | 8 --------
>  6 files changed, 15 insertions(+), 14 deletions(-)

> +#if defined(CONFIG_RANDOMIZE_MEMORY) || defined(CONFIG_X86_5LEVEL)
> +#if defined(CONFIG_RANDOMIZE_MEMORY) || defined(CONFIG_X86_5LEVEL)
> +#if defined(CONFIG_RANDOMIZE_MEMORY) || defined(CONFIG_X86_5LEVEL)

Yeah, so this calls for a new, properly named Kconfig helper variable.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
