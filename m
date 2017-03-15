Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6336C6B0388
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 05:23:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g10so1996839wrg.5
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 02:23:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x204si3301194wmg.164.2017.03.15.02.23.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 02:23:43 -0700 (PDT)
Date: Wed, 15 Mar 2017 10:23:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] x86: 5-level paging enabling for v4.12, Part 1
Message-ID: <20170315092341.GF32620@dhcp22.suse.cz>
References: <20170313143309.16020-1-kirill.shutemov@linux.intel.com>
 <20170314074729.GA23151@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170314074729.GA23151@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 14-03-17 08:47:29, Ingo Molnar wrote:
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

JFYI, I have cherry picked these and those merged via Linus tree into
the mmotm git tree [1] (tag mmotm-2017-03-14-15-41)

[1] git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
