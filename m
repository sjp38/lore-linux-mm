Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1156B0290
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:44:26 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a80so1052317wme.2
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:44:26 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id d8si2458730edn.329.2018.01.16.11.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 11:44:25 -0800 (PST)
Date: Tue, 16 Jan 2018 20:44:24 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 12/16] x86/mm/pae: Populate the user page-table with user
 pgd's
Message-ID: <20180116194424.GE28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-13-git-send-email-joro@8bytes.org>
 <df637ada-c2f6-c137-0287-0964e29fc11f@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <df637ada-c2f6-c137-0287-0964e29fc11f@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Tue, Jan 16, 2018 at 10:11:14AM -0800, Dave Hansen wrote:
> 
> Ugh.  The ghosts of PAE have come back to haunt us.

:-) Yeah, PAE caused the most trouble for me while getting this running.

> 
> Could we do:
> 
> static inline bool pgd_supports_nx(unsigned long)
> {
> #ifdef CONFIG_X86_64
> 	return (__supported_pte_mask & _PAGE_NX);
> #else
> 	/* No 32-bit page tables support NX at PGD level */
> 	return 0;
> #endif
> }
> 
> Nobody will ever spot the #ifdef the way you laid it out.

Right, thats a better way to do it. I'll change it in the next version.

Thanks,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
