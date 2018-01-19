Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 274A66B026B
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:57:53 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 33so926637wrs.3
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 01:57:53 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id o91si538498eda.277.2018.01.19.01.57.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 01:57:52 -0800 (PST)
Date: Fri, 19 Jan 2018 10:57:51 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 08/16] x86/pgtable/32: Allocate 8k page-tables when PTI
 is enabled
Message-ID: <20180119095751.GA28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-9-git-send-email-joro@8bytes.org>
 <CALCETrU1HOJa6i5aLjEBPjw6B6KmzBXCig9m-iawVt63P1ZpUQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrU1HOJa6i5aLjEBPjw6B6KmzBXCig9m-iawVt63P1ZpUQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Wed, Jan 17, 2018 at 03:43:14PM -0800, Andy Lutomirski wrote:
> On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
> >  #ifdef CONFIG_X86_PAE
> >  .globl initial_pg_pmd
> >  initial_pg_pmd:
> >         .fill 1024*KPMDS,4,0
> > +       .fill PTI_USER_PGD_FILL,4,0
> 
> Couldn't this be simplified to just .align PGD_ALIGN, 0 without the .fill?

You are right, will change that.

Thanks,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
