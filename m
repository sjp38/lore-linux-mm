Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 81CB56B000A
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 03:26:09 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g63-v6so5905230pfc.9
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 00:26:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h10-v6sor3002229pgv.59.2018.10.25.00.26.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 00:26:08 -0700 (PDT)
Date: Thu, 25 Oct 2018 10:26:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] x86/ldt: Unmap PTEs for the slow before freeing LDT
Message-ID: <20181025072602.cz3vy2zhzq2px7ik@kshutemo-mobl1>
References: <20181023163157.41441-1-kirill.shutemov@linux.intel.com>
 <20181023163157.41441-3-kirill.shutemov@linux.intel.com>
 <CALCETrUsqCzU6VO0h4EFpsdXOOn-kJY7ogwKQiQScNY9YJ6hWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUsqCzU6VO0h4EFpsdXOOn-kJY7ogwKQiQScNY9YJ6hWA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 24, 2018 at 11:49:17AM -0700, Andy Lutomirski wrote:
> On Tue, Oct 23, 2018 at 9:32 AM Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> > modify_ldt(2) leaves old LDT mapped after we switch over to the new one.
> > Memory for the old LDT gets freed and the pages can be re-used.
> >
> > Leaving the mapping in place can have security implications. The mapping
> > is present in userspace copy of page tables and Meltdown-like attack can
> > read these freed and possibly reused pages.
> 
> Code looks okay.  But:
> 
> > -       /*
> > -        * Did we already have the top level entry allocated?  We can't
> > -        * use pgd_none() for this because it doens't do anything on
> > -        * 4-level page table kernels.
> > -        */
> > -       pgd = pgd_offset(mm, LDT_BASE_ADDR);
> 
> This looks like an unrelated cleanup.  Can it be its own patch?

Okay, I'll move it into a separate patch in v3.

I'll some more time for comments on v2 before respin.

-- 
 Kirill A. Shutemov
