Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9135B6B0266
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:05:23 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f64so18454473pfd.6
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:05:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f7si11899535pgc.324.2017.12.12.10.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 10:05:22 -0800 (PST)
Date: Tue, 12 Dec 2017 19:05:09 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Message-ID: <20171212180509.iewpmzdhvsusk2nk@hirez.programming.kicks-ass.net>
References: <20171212173221.496222173@linutronix.de>
 <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 10:00:08AM -0800, Andy Lutomirski wrote:
> On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > From: Peter Zijstra <peterz@infradead.org>
> >
> > In order to create VMAs that are not accessible to userspace create a new
> > VM_NOUSER flag. This can be used in conjunction with
> > install_special_mapping() to inject 'kernel' data into the userspace map.
> >
> > Similar to how arch_vm_get_page_prot() allows adding _PAGE_flags to
> > pgprot_t, introduce arch_vm_get_page_prot_excl() which masks
> > _PAGE_flags from pgprot_t and use this to implement VM_NOUSER for x86.
> 
> How does this interact with get_user_pages(), etc?

gup would find the page. These patches do in fact rely on that through
the populate things.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
