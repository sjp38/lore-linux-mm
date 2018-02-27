Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 726B26B0005
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:14:48 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id f15so7592105wmd.1
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 00:14:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a17sor4847485eda.6.2018.02.27.00.14.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Feb 2018 00:14:46 -0800 (PST)
Date: Tue, 27 Feb 2018 11:14:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/5] x86/boot/compressed/64: Find a place for 32-bit
 trampoline
Message-ID: <20180227081437.epg5tmhg7gfzunwp@node.shutemov.name>
References: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
 <20180226180451.86788-3-kirill.shutemov@linux.intel.com>
 <20180226223038.GI14140@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180226223038.GI14140@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 26, 2018 at 11:30:38PM +0100, Borislav Petkov wrote:
> On Mon, Feb 26, 2018 at 09:04:48PM +0300, Kirill A. Shutemov wrote:
> > +++ b/arch/x86/boot/compressed/pgtable.h
> > @@ -0,0 +1,11 @@
> > +#ifndef BOOT_COMPRESSED_PAGETABLE_H
> > +#define BOOT_COMPRESSED_PAGETABLE_H
> > +
> > +#define TRAMPOLINE_32BIT_SIZE		(2 * PAGE_SIZE)
> > +
> > +#ifndef __ASSEMBLER__
> 
> x86 uses __ASSEMBLY__ everywhere and I see
> 
> arch/x86/boot/compressed/Makefile:41:KBUILD_AFLAGS  := $(KBUILD_CFLAGS) -D__ASSEMBLY__
> 
> so it should work here too.
> 
> Even though __ASSEMBLER__ is gcc predefined.

Okay, I'll fix this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
