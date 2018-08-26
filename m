Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 288126B394F
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 02:06:18 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id n17-v6so9103537pff.17
        for <linux-mm@kvack.org>; Sat, 25 Aug 2018 23:06:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h36-v6si10823286pgm.125.2018.08.25.23.06.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Aug 2018 23:06:17 -0700 (PDT)
Date: Sun, 26 Aug 2018 08:06:12 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 4.4 037/107] x86/mm: Factor out LDT init from context init
Message-ID: <20180826060612.GA21746@kroah.com>
References: <20180723122413.003644357@linuxfoundation.org>
 <20180723122414.735940678@linuxfoundation.org>
 <1535154250.2902.63.camel@codethink.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1535154250.2902.63.camel@codethink.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave@sr71.net>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>, "Matt Helsley (VMware)" <matt.helsley@gmail.com>, Alexey Makhalov <amakhalov@vmware.com>, Bo Gan <ganb@vmware.com>

On Sat, Aug 25, 2018 at 12:44:10AM +0100, Ben Hutchings wrote:
> On Mon, 2018-07-23 at 14:41 +0200, Greg Kroah-Hartman wrote:
> > 4.4-stable review patch.  If anyone has any objections, please let me know.
> > 
> > ------------------
> > 
> > From: Dave Hansen <dave.hansen@linux.intel.com>
> > 
> > commit 39a0526fb3f7d93433d146304278477eb463f8af upstream
> [...]
> > --- a/arch/x86/include/asm/mmu_context.h
> > +++ b/arch/x86/include/asm/mmu_context.h
> [...]
> > +static inline int init_new_context(struct task_struct *tsk,
> > +				   struct mm_struct *mm)
> > +{
> > +	init_new_context_ldt(tsk, mm);
> > +	return 0;
> > +}
> [...]
> 
> This hides errors from init_new_context_ldt(), which is very bad.
> Fixed upstream by:
> 
> commit ccd5b3235180eef3cfec337df1c8554ab151b5cc
> Author: Eric Biggers <ebiggers@google.com>
> Date:   Thu Aug 24 10:50:29 2017 -0700
> 
>     x86/mm: Fix use-after-free of ldt_struct
> 
> Ben.

Good catch, now applied, thanks.

greg k-h
