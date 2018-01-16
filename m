Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE6C6B025E
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:27:12 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id l14so1227087uaa.17
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:27:12 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id w1si3020044edk.223.2018.01.16.11.11.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 11:11:06 -0800 (PST)
Date: Tue, 16 Jan 2018 20:11:05 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 07/16] x86/mm: Move two more functions from pgtable_64.h
 to pgtable.h
Message-ID: <20180116191105.GC28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-8-git-send-email-joro@8bytes.org>
 <727a7eba-41a0-d5bb-df54-8e58b33fde76@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <727a7eba-41a0-d5bb-df54-8e58b33fde76@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Tue, Jan 16, 2018 at 10:03:09AM -0800, Dave Hansen wrote:
> On 01/16/2018 08:36 AM, Joerg Roedel wrote:
> > +	return (((ptr & ~PAGE_MASK) / sizeof(pgd_t)) < KERNEL_PGD_BOUNDARY);
> > +}
> 
> One of the reasons to implement it the other way:
> 
> -	return (ptr & ~PAGE_MASK) < (PAGE_SIZE / 2);
> 
> is that the compiler can do this all quickly.  KERNEL_PGD_BOUNDARY
> depends on PAGE_OFFSET which depends on a variable.  IOW, the compiler
> can't do it.
> 
> How much worse is the code that this generates?

I havn't looked at the actual code this generates, but the
(PAGE_SIZE / 2) comparison doesn't work on 32 bit where the address
space is not always evenly split. I'll look into a better way to check
this.

Thanks,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
