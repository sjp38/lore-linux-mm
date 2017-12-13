Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF1A6B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:05:08 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id r140so2369570iod.12
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:05:08 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a39si1640357itj.83.2017.12.13.07.05.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 07:05:07 -0800 (PST)
Date: Wed, 13 Dec 2017 16:04:53 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Message-ID: <20171213150453.bj45oflflaevvqig@hirez.programming.kicks-ass.net>
References: <20171212173221.496222173@linutronix.de>
 <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
 <20171213125739.fllckbl3o4nonmpx@node.shutemov.name>
 <20171213143455.oqigy6m53qhuu7k4@hirez.programming.kicks-ass.net>
 <20171213144339.ii5gk2arwg5ivr6b@node.shutemov.name>
 <20171213150007.fonxub6yzjh2iu2c@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213150007.fonxub6yzjh2iu2c@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com

On Wed, Dec 13, 2017 at 04:00:07PM +0100, Peter Zijlstra wrote:
> On Wed, Dec 13, 2017 at 05:43:39PM +0300, Kirill A. Shutemov wrote:
> > > am I perchance looking at the wrong tee?
> > 
> > I'm looking at Linus' tree.
> 
> Clearly I'm not synced up enough... :/
> 
> > It was changed recently:
> > 	5c9d2d5c269c ("mm: replace pte_write with pte_access_permitted in fault + gup paths")
> > 
> 
> Indeed. So FOLL_GET should also get these tests and, as you said, the
> other levels too.
> 
> I would like FOLL_POPULATE (doesn't have FOLL_GET) to be allowed
> 'access'.

Similarly, should we avoid arch_vma_access_permitted() if !FOLL_GET ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
