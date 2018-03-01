Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2BABA6B0006
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 07:03:32 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u83so3373323wmb.3
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 04:03:32 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id h93si477742edc.283.2018.03.01.04.03.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 04:03:27 -0800 (PST)
Date: Thu, 1 Mar 2018 13:03:26 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 12/31] x86/entry/32: Add PTI cr3 switch to non-NMI
 entry/exit points
Message-ID: <20180301120326.GN16484@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-13-git-send-email-joro@8bytes.org>
 <afd5bae9-f53e-a225-58f1-4ba2422044e3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <afd5bae9-f53e-a225-58f1-4ba2422044e3@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

On Tue, Feb 27, 2018 at 02:18:36PM -0500, Waiman Long wrote:
> On 02/09/2018 04:25 AM, Joerg Roedel wrote:
> >  	SAVE_ALL
> >  	ENCODE_FRAME_POINTER
> > +
> > +	/* Make sure we are running on kernel cr3 */
> > +	SWITCH_TO_KERNEL_CR3 scratch_reg=%eax
> > +
> >  	xorl	%edx, %edx			# error code 0
> >  	movl	%esp, %eax			# pt_regs pointer
> >  
> 
> The debug exception calls ret_from_exception on exit. If coming from
> userspace, the C function prepare_exit_to_usermode() will be called.
> With the PTI-32 code, it means that function will be called with the
> entry stack instead of the task stack. This can be problematic as macro
> like current won't work anymore.

This is not different from before, no? The debug handler already can be
entered on entry stack before this patch-set.


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
