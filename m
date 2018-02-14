Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 127EE6B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 07:19:16 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e1so755571pfn.13
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 04:19:16 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 37-v6si2682948plc.715.2018.02.14.04.19.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 04:19:15 -0800 (PST)
Date: Wed, 14 Feb 2018 15:19:10 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 9/9] x86/mm: Adjust virtual address space layout in early
 boot
Message-ID: <20180214121910.yvnm7wcejpjux6eo@black.fi.intel.com>
References: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
 <20180214111656.88514-10-kirill.shutemov@linux.intel.com>
 <20180214121049.z4cjsdwxaaq5gpv5@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180214121049.z4cjsdwxaaq5gpv5@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 14, 2018 at 12:10:49PM +0000, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> 
> > We need to adjust virtual address space to support switching between
> > paging modes.
> > 
> > The adjustment happens in __startup_64().
> > 
> > We also have to change KASLR code that doesn't expect variable
> > VMALLOC_SIZE_TB.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/boot/compressed/kaslr.c        | 14 ++++++++--
> >  arch/x86/include/asm/page_64_types.h    |  9 ++----
> >  arch/x86/include/asm/pgtable_64_types.h | 25 +++++++++--------
> >  arch/x86/kernel/head64.c                | 49 +++++++++++++++++++++++++++------
> >  arch/x86/kernel/head_64.S               |  2 +-
> >  arch/x86/mm/dump_pagetables.c           |  3 ++
> >  arch/x86/mm/kaslr.c                     | 11 ++++----
> >  7 files changed, 77 insertions(+), 36 deletions(-)
> 
> This is too large and risky - would it be possible to split this up into multiple, 
> smaller patches?

Let me check what I can do here.

If you are fine with previous patches please apply. I will send split up
of this patch separately.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
