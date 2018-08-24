Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 419456B3231
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 19:44:47 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id z77-v6so9014940wrb.20
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 16:44:47 -0700 (PDT)
Received: from imap1.codethink.co.uk (imap1.codethink.co.uk. [176.9.8.82])
        by mx.google.com with ESMTPS id o16-v6si1804562wmh.19.2018.08.24.16.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 16:44:45 -0700 (PDT)
Message-ID: <1535154250.2902.63.camel@codethink.co.uk>
Subject: Re: [PATCH 4.4 037/107] x86/mm: Factor out LDT init from context
 init
From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Date: Sat, 25 Aug 2018 00:44:10 +0100
In-Reply-To: <20180723122414.735940678@linuxfoundation.org>
References: <20180723122413.003644357@linuxfoundation.org>
	 <20180723122414.735940678@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave@sr71.net>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>, "Matt Helsley (VMware)" <matt.helsley@gmail.com>, Alexey Makhalov <amakhalov@vmware.com>, Bo Gan <ganb@vmware.com>

On Mon, 2018-07-23 at 14:41 +0200, Greg Kroah-Hartman wrote:
> 4.4-stable review patch.A A If anyone has any objections, please let me know.
> 
> ------------------
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> commit 39a0526fb3f7d93433d146304278477eb463f8af upstream
[...]
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
[...]
> +static inline int init_new_context(struct task_struct *tsk,
> +				A A A struct mm_struct *mm)
> +{
> +	init_new_context_ldt(tsk, mm);
> +	return 0;
> +}
[...]

This hides errors from init_new_context_ldt(), which is very bad.
Fixed upstream by:

commit ccd5b3235180eef3cfec337df1c8554ab151b5cc
Author: Eric Biggers <ebiggers@google.com>
Date:   Thu Aug 24 10:50:29 2017 -0700

    x86/mm: Fix use-after-free of ldt_struct

Ben.

-- 
Ben Hutchings, Software Developer                A         Codethink Ltd
https://www.codethink.co.uk/                 Dale House, 35 Dale Street
                                     Manchester, M1 2HF, United Kingdom
