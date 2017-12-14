Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D34066B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 12:37:08 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 3so5265856pfo.1
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 09:37:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y20si3157505pgv.291.2017.12.14.09.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 09:37:06 -0800 (PST)
Date: Thu, 14 Dec 2017 18:36:53 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 02/17] mm: Exempt special mappings from mlock(),
 mprotect() and madvise()
Message-ID: <20171214173653.s6vsgiwfty3tzyzs@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org>
 <20171214113851.197682513@infradead.org>
 <CALCETrXzaa8svjHdm3G3=FKvAZoQx-CboE6YecdPsva+Lf_bJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXzaa8svjHdm3G3=FKvAZoQx-CboE6YecdPsva+Lf_bJg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 08:19:36AM -0800, Andy Lutomirski wrote:
> On Thu, Dec 14, 2017 at 3:27 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > It makes no sense to ever prod at special mappings with any of these
> > syscalls.
> >
> > XXX should we include munmap() ?
> 
> This is an ABI break for the vdso.  Maybe that's okay, but mremap() on
> the vdso is certainly used, and I can imagine debuggers using
> mprotect().

*groan*, ok so mremap() will actually still work after this, but yes,
mprotect() will not. I hadn't figured people would muck with the VDSO
like that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
