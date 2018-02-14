Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 259746B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 05:00:21 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id s18so12646765wrg.5
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 02:00:21 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id l52si2982237edb.260.2018.02.14.02.00.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 02:00:17 -0800 (PST)
Date: Wed, 14 Feb 2018 11:00:15 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 19/31] x86/mm/pae: Populate valid user PGD entries
Message-ID: <20180214100014.GG16484@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-20-git-send-email-joro@8bytes.org>
 <3913f255-7309-58c5-b6c3-39cf0e29a844@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3913f255-7309-58c5-b6c3-39cf0e29a844@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

Hi Juergen,

On Wed, Feb 14, 2018 at 10:45:53AM +0100, Juergen Gross wrote:
> On 09/02/18 10:25, Joerg Roedel wrote:
> > +#ifdef CONFIG_X86_PAE
> > +
> > +/*
> > + * PHYSICAL_PAGE_MASK might be non-constant when SME is compiled in, so we can't
> > + * use it here.
> > + */
> > +#define PGD_PAE_PHYS_MASK	(((1ULL << __PHYSICAL_MASK_SHIFT)-1) & PAGE_MASK)
> 
> I think PAGE_MASK is a 32 bit value here, so you are chopping off
> the high physical address bits.
> 
> With that corrected the kernel is coming up as Xen PV guest.

Cool, thanks for testing these patches and debugging the breakage on
Xen-PV. I'll fix that in the next version.


Thanks again,

       Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
