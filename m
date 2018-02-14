Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CCD3F6B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 07:10:53 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g16so5681478wmg.6
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 04:10:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f90sor633991wmh.50.2018.02.14.04.10.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 04:10:52 -0800 (PST)
Date: Wed, 14 Feb 2018 13:10:49 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 9/9] x86/mm: Adjust virtual address space layout in early
 boot
Message-ID: <20180214121049.z4cjsdwxaaq5gpv5@gmail.com>
References: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
 <20180214111656.88514-10-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180214111656.88514-10-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> We need to adjust virtual address space to support switching between
> paging modes.
> 
> The adjustment happens in __startup_64().
> 
> We also have to change KASLR code that doesn't expect variable
> VMALLOC_SIZE_TB.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/boot/compressed/kaslr.c        | 14 ++++++++--
>  arch/x86/include/asm/page_64_types.h    |  9 ++----
>  arch/x86/include/asm/pgtable_64_types.h | 25 +++++++++--------
>  arch/x86/kernel/head64.c                | 49 +++++++++++++++++++++++++++------
>  arch/x86/kernel/head_64.S               |  2 +-
>  arch/x86/mm/dump_pagetables.c           |  3 ++
>  arch/x86/mm/kaslr.c                     | 11 ++++----
>  7 files changed, 77 insertions(+), 36 deletions(-)

This is too large and risky - would it be possible to split this up into multiple, 
smaller patches?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
