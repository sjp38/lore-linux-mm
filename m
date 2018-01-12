Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0037E6B0038
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 03:38:04 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id s105so2931108wrc.23
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 00:38:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13sor12046511edk.31.2018.01.12.00.38.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jan 2018 00:38:02 -0800 (PST)
Date: Fri, 12 Jan 2018 11:37:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 0/4] x86: 5-level related changes into decompression
 code<Paste>
Message-ID: <20180112083757.okwsvdhqaodt2d3u@node.shutemov.name>
References: <20171212135739.52714-1-kirill.shutemov@linux.intel.com>
 <20171218101045.arwbzmbxbhqgreeu@node.shutemov.name>
 <20180108161805.jrpmkcrwlr2rs4sy@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180108161805.jrpmkcrwlr2rs4sy@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 08, 2018 at 05:18:05PM +0100, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> 
> > On Tue, Dec 12, 2017 at 04:57:35PM +0300, Kirill A. Shutemov wrote:
> > > Here's few changes to x86 decompression code.
> > > 
> > > The first patch is pure cosmetic change: it gives file with KASLR helpers
> > > a proper name.
> > > 
> > > The last three patches bring support of booting into 5-level paging mode if
> > > a bootloader put the kernel above 4G.
> > > 
> > > Patch 2/4 Renames l5_paging_required() into paging_prepare() and change
> > > interface of the function.
> > > Patch 3/4 Handles allocation of space for trampoline and gets it prepared.
> > > Patch 4/4 Gets trampoline used.
> > > 
> > > Kirill A. Shutemov (4):
> > >   x86/boot/compressed/64: Rename pagetable.c to kaslr_64.c
> > >   x86/boot/compressed/64: Introduce paging_prepare()
> > >   x86/boot/compressed/64: Prepare trampoline memory
> > >   x86/boot/compressed/64: Handle 5-level paging boot if kernel is above
> > >     4G
> > 
> > Ingo, does it look fine now?
> 
> Yes, it looks structurally much better now - but we first need to address all 
> existing regressions before we can move forward.

There's a fix for kdump issue that maintainers are okay about.

Is there any other regression do you have in mind?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
