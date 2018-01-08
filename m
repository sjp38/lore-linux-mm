Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A85346B02A2
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 11:18:09 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b82so3899509wmd.5
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 08:18:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m75sor3169941wmi.50.2018.01.08.08.18.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 08:18:08 -0800 (PST)
Date: Mon, 8 Jan 2018 17:18:05 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv6 0/4] x86: 5-level related changes into decompression
 code<Paste>
Message-ID: <20180108161805.jrpmkcrwlr2rs4sy@gmail.com>
References: <20171212135739.52714-1-kirill.shutemov@linux.intel.com>
 <20171218101045.arwbzmbxbhqgreeu@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171218101045.arwbzmbxbhqgreeu@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Tue, Dec 12, 2017 at 04:57:35PM +0300, Kirill A. Shutemov wrote:
> > Here's few changes to x86 decompression code.
> > 
> > The first patch is pure cosmetic change: it gives file with KASLR helpers
> > a proper name.
> > 
> > The last three patches bring support of booting into 5-level paging mode if
> > a bootloader put the kernel above 4G.
> > 
> > Patch 2/4 Renames l5_paging_required() into paging_prepare() and change
> > interface of the function.
> > Patch 3/4 Handles allocation of space for trampoline and gets it prepared.
> > Patch 4/4 Gets trampoline used.
> > 
> > Kirill A. Shutemov (4):
> >   x86/boot/compressed/64: Rename pagetable.c to kaslr_64.c
> >   x86/boot/compressed/64: Introduce paging_prepare()
> >   x86/boot/compressed/64: Prepare trampoline memory
> >   x86/boot/compressed/64: Handle 5-level paging boot if kernel is above
> >     4G
> 
> Ingo, does it look fine now?

Yes, it looks structurally much better now - but we first need to address all 
existing regressions before we can move forward.

( Also, the PTI work created a bit of a distraction as well, but x86 patch 
  integration should should be back to speed soon. )

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
