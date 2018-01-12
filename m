Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7DE6B0033
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 11:22:21 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w141so3425768wme.1
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 08:22:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f28sor3703632edd.4.2018.01.12.08.22.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jan 2018 08:22:19 -0800 (PST)
Date: Fri, 12 Jan 2018 19:22:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 0/4] x86: 5-level related changes into decompression
 code<Paste>
Message-ID: <20180112162217.oeyf4jjgqur3zutn@node.shutemov.name>
References: <20171212135739.52714-1-kirill.shutemov@linux.intel.com>
 <20171218101045.arwbzmbxbhqgreeu@node.shutemov.name>
 <20180108161805.jrpmkcrwlr2rs4sy@gmail.com>
 <20180112083757.okwsvdhqaodt2d3u@node.shutemov.name>
 <20180112141037.ktd2ryzx3tfwhsfx@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180112141037.ktd2ryzx3tfwhsfx@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 12, 2018 at 03:10:37PM +0100, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> 
> > On Mon, Jan 08, 2018 at 05:18:05PM +0100, Ingo Molnar wrote:
> > > 
> > > * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > > 
> > > > On Tue, Dec 12, 2017 at 04:57:35PM +0300, Kirill A. Shutemov wrote:
> > > > > Here's few changes to x86 decompression code.
> > > > > 
> > > > > The first patch is pure cosmetic change: it gives file with KASLR helpers
> > > > > a proper name.
> > > > > 
> > > > > The last three patches bring support of booting into 5-level paging mode if
> > > > > a bootloader put the kernel above 4G.
> > > > > 
> > > > > Patch 2/4 Renames l5_paging_required() into paging_prepare() and change
> > > > > interface of the function.
> > > > > Patch 3/4 Handles allocation of space for trampoline and gets it prepared.
> > > > > Patch 4/4 Gets trampoline used.
> > > > > 
> > > > > Kirill A. Shutemov (4):
> > > > >   x86/boot/compressed/64: Rename pagetable.c to kaslr_64.c
> > > > >   x86/boot/compressed/64: Introduce paging_prepare()
> > > > >   x86/boot/compressed/64: Prepare trampoline memory
> > > > >   x86/boot/compressed/64: Handle 5-level paging boot if kernel is above
> > > > >     4G
> > > > 
> > > > Ingo, does it look fine now?
> > > 
> > > Yes, it looks structurally much better now - but we first need to address all 
> > > existing regressions before we can move forward.
> > 
> > There's a fix for kdump issue that maintainers are okay about.
> 
> Do you mean your proposed fix in:
> 
>   Message-ID: <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
> 
> ?
> 
> I was expecting a final submission of that fix in a new thread (or at least with a 
> new subject line), with all Acked-by and Tested-by's collected and Reported-by 
> added in.

Okay, I'll do this.

I just thought that it will go via -mm tree and Andrew is usually okay with
collecting acks on his own.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
