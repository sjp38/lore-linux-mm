Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 56C336B025F
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 11:31:52 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e70so2855238wmc.6
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:31:52 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k198si3357801wmg.178.2017.12.14.08.31.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 08:31:51 -0800 (PST)
Date: Thu, 14 Dec 2017 17:31:11 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 14/17] x86/ldt: Reshuffle code
In-Reply-To: <CALCETrU5H_X6kfOxnsb1d92oUJHa-6kWm=BWANYD9JJgDD=YOA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1712141730410.4998@nanos>
References: <20171214112726.742649793@infradead.org> <20171214113851.797295832@infradead.org> <CALCETrU5H_X6kfOxnsb1d92oUJHa-6kWm=BWANYD9JJgDD=YOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>


On Thu, 14 Dec 2017, Andy Lutomirski wrote:

> On Thu, Dec 14, 2017 at 3:27 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > From: Thomas Gleixner <tglx@linutronix.de>
> >
> > Restructure the code, so the following VMA changes do not create an
> > unreadable mess. No functional change.
> 
> Can the PF_KTHREAD thing be its own patch so it can be reviewed on its own?

I had that as a separate patch at some point.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
