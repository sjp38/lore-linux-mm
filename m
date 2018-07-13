Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB88E6B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 05:49:46 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s3-v6so1741227eds.15
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 02:49:46 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id k32-v6si40686edc.340.2018.07.13.02.49.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 02:49:43 -0700 (PDT)
Date: Fri, 13 Jul 2018 11:48:49 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 03/39] x86/entry/32: Load task stack from x86_tss.sp1 in
 SYSENTER handler
Message-ID: <20180713094849.5bsfpwhxzo5r5exk@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-4-git-send-email-joro@8bytes.org>
 <823BAA9B-FACA-4E91-BE56-315FF569297C@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <823BAA9B-FACA-4E91-BE56-315FF569297C@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de

On Thu, Jul 12, 2018 at 01:49:13PM -0700, Andy Lutomirski wrote:
> > On Jul 11, 2018, at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
> >    /* Offset from the sysenter stack to tss.sp0 */
> > -    DEFINE(TSS_entry_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp0) -
> > +    DEFINE(TSS_entry_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp1) -
> >           offsetofend(struct cpu_entry_area, entry_stack_page.stack));
> > 
> 
> The code reads differently. Did you perhaps mean TSS_task_stack?

Well, the offset name came from TSS_sysenter_sp0, which was the offset
from the sysenter_sp0 (==sysenter-stack) to the task stack in TSS, now
sysenter_sp0 became entry_stack, because its used for all entry points
and not only sysenter. So with the old convention the naming makes still
sense, no?

> Also, the a??top of task stacka?? is a bit weird on 32-bit due to vm86.
> Can you document *exactly* what goes in sp1?

Will do, thanks for your feedback!


	Joerg
