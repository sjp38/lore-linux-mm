Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7439D280281
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 04:26:59 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d63so3634808wma.4
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 01:26:59 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id y5si4347351edj.28.2018.01.17.01.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 01:26:58 -0800 (PST)
Date: Wed, 17 Jan 2018 10:26:57 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 04/16] x86/pti: Define X86_CR3_PTI_PCID_USER_BIT on x86_32
Message-ID: <20180117092657.GK28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-5-git-send-email-joro@8bytes.org>
 <CALCETrXFuXo+nDm0ovS6e7F5-aALMCwZdX=H6C=pLkAArDaYMQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXFuXo+nDm0ovS6e7F5-aALMCwZdX=H6C=pLkAArDaYMQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 02:46:16PM -0800, Andy Lutomirski wrote:
> On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > From: Joerg Roedel <jroedel@suse.de>
> >
> > Move it out of the X86_64 specific processor defines so
> > that its visible for 32bit too.
> 
> Hmm.  This is okay, I guess, but any code that actually uses this
> definition is inherently wrong, since 32-bit implies !PCID.

Yes, I tried another approach first which just #ifdef'ed out the
relevant parts in tlbflush.h which use this bit. But that seemed to be
the wrong path, as there is more PCID code that is compiled in for 32
bit. So defining the bit for 32 bit seemed to be the cleaner solution
for now.


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
