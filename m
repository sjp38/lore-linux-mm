Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 50C026B025F
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 09:26:12 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r74so2247087wme.5
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 06:26:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g27sor1045305edf.39.2017.09.28.06.26.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 06:26:10 -0700 (PDT)
Date: Thu, 28 Sep 2017 16:26:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv7 12/19] x86/mm: Adjust virtual address space layout in
 early boot.
Message-ID: <20170928132608.priml7nc7dmo5r6d@node.shutemov.name>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-13-kirill.shutemov@linux.intel.com>
 <20170928083155.7qahecaeifz5em5f@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170928083155.7qahecaeifz5em5f@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 28, 2017 at 10:31:55AM +0200, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> 
> > We need to adjust virtual address space to support switching between
> > paging modes.
> > 
> > The adjustment happens in __startup_64().
> 
> > +#ifdef CONFIG_X86_5LEVEL
> > +	if (__read_cr4() & X86_CR4_LA57) {
> > +		pgtable_l5_enabled = 1;
> > +		pgdir_shift = 48;
> > +		ptrs_per_p4d = 512;
> > +	}
> > +#endif
> 
> So CR4 really sucks as a parameter passing interface - was it us who enabled LA57 
> in the early boot code, right? Couldn't we add a flag which gets set there, or 
> something?

It's not necessary that we enabled LA57. At least I tried to write code
that doesn't assume this. We enable it if bootloader haven't done this
already for us.

What is so awful about using CR4 as passing interface? It's one-time
check, so performance shouldn't be an issue.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
