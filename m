Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 30FAE6B0388
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 04:24:13 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n11so17718313wma.5
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 01:24:13 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id d7si4065710wrc.336.2017.03.14.01.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 01:24:11 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id n11so13524921wma.0
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 01:24:11 -0700 (PDT)
Date: Tue, 14 Mar 2017 11:24:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/6] x86: 5-level paging enabling for v4.12, Part 1
Message-ID: <20170314082409.gjhefteglqbfb2gy@node.shutemov.name>
References: <20170313143309.16020-1-kirill.shutemov@linux.intel.com>
 <20170314074729.GA23151@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170314074729.GA23151@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 14, 2017 at 08:47:29AM +0100, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> 
> > Here's the first bunch of patches of 5-level patchset. Let's see if I'm on
> > right track addressing Ingo's feedback. :)
> > 
> > These patches prepare x86 code to be switched from <asm-generic/5level-fixup>
> > to <asm-generic/pgtable-nop4d.h>. It's a stepping stone for adding 5-level
> > paging support.
> > 
> > Please review and consider applying.
> > 
> > Kirill A. Shutemov (6):
> >   x86/mm: Extend headers with basic definitions to support 5-level
> >     paging
> >   x86/mm: Convert trivial cases of page table walk to 5-level paging
> >   x86/gup: Add 5-level paging support
> >   x86/ident_map: Add 5-level paging support
> >   x86/vmalloc: Add 5-level paging support
> >   x86/power: Add 5-level paging support
> > 
> >  arch/x86/include/asm/pgtable-2level_types.h |  1 +
> >  arch/x86/include/asm/pgtable-3level_types.h |  1 +
> >  arch/x86/include/asm/pgtable.h              | 26 +++++++++---
> >  arch/x86/include/asm/pgtable_64_types.h     |  1 +
> >  arch/x86/include/asm/pgtable_types.h        | 30 ++++++++++++-
> >  arch/x86/kernel/tboot.c                     |  6 ++-
> >  arch/x86/kernel/vm86_32.c                   |  6 ++-
> >  arch/x86/mm/fault.c                         | 66 +++++++++++++++++++++++++----
> >  arch/x86/mm/gup.c                           | 33 ++++++++++++---
> >  arch/x86/mm/ident_map.c                     | 51 +++++++++++++++++++---
> >  arch/x86/mm/init_32.c                       | 22 +++++++---
> >  arch/x86/mm/ioremap.c                       |  3 +-
> >  arch/x86/mm/pgtable.c                       |  4 +-
> >  arch/x86/mm/pgtable_32.c                    |  8 +++-
> >  arch/x86/platform/efi/efi_64.c              | 13 ++++--
> >  arch/x86/power/hibernate_32.c               |  7 ++-
> >  arch/x86/power/hibernate_64.c               | 50 ++++++++++++++++------
> >  17 files changed, 269 insertions(+), 59 deletions(-)
> 
> Much better!
> 
> I've applied them, with (very) minor readability edits here and there, and will 
> push them out into tip:x86/mm and tip:master after some testing - you can use that 
> as a base for the remaining submissions.

Thanks.

> I've also applied the GUP patch, with the assumption that you'll address Linus's 
> request to switch x86 over to the generic version.

Okay, I'll do this.

I just want to make priorities clear here: is it okay to finish with the
rest of 5-level paging patches first before moving to GUP_fast switch?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
