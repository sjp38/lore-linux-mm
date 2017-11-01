Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 79A2A6B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 06:11:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e8so1100372wmc.2
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 03:11:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r30sor366663edb.49.2017.11.01.03.11.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 03:11:49 -0700 (PDT)
Date: Wed, 1 Nov 2017 13:11:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 04/23] x86, tlb: make CR4-based TLB flushes more robust
Message-ID: <20171101101147.x2gvag62zpzydgr3@node.shutemov.name>
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223154.67F15B2A@viggo.jf.intel.com>
 <CALCETrW06XjaWYD1O_HPXPDrHS96FZz9=OkPCQ3vsKrAxnr8+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrW06XjaWYD1O_HPXPDrHS96FZz9=OkPCQ3vsKrAxnr8+A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Wed, Nov 01, 2017 at 01:01:45AM -0700, Andy Lutomirski wrote:
> On Tue, Oct 31, 2017 at 3:31 PM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
> >
> > Our CR4-based TLB flush currently requries global pages to be
> > supported *and* enabled.  But, we really only need for them to be
> > supported.  Make the code more robust by alllowing X86_CR4_PGE to
> > clear as well as set.
> >
> > This change was suggested by Kirill Shutemov.
> 
> I may have missed something, but why would be ever have CR4.PGE off?

This came out from me thinking on if we can disable global pages by not
turning on CR4.PGE instead of making _PAGE_GLOBAL zero.

Dave decided to not take this path, but this change would make
__native_flush_tlb_global_irq_disabled() a bit less fragile in case
if the situation would change in the future.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
