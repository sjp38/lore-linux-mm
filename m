Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 29A326B0038
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 12:47:41 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x24so4651654pgv.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 09:47:41 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o33si3459441plb.489.2017.12.14.09.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 09:47:39 -0800 (PST)
Date: Thu, 14 Dec 2017 18:47:30 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 14/17] x86/ldt: Reshuffle code
Message-ID: <20171214174730.3zrzruplyw5k4plc@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org>
 <20171214113851.797295832@infradead.org>
 <CALCETrU5H_X6kfOxnsb1d92oUJHa-6kWm=BWANYD9JJgDD=YOA@mail.gmail.com>
 <alpine.DEB.2.20.1712141730410.4998@nanos>
 <alpine.DEB.2.20.1712141731540.4998@nanos>
 <CALCETrXbFA2Pm5-9a8MCXJkm8hLW9fZuW7DxbdZJ-mCQ2Ozd8A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXbFA2Pm5-9a8MCXJkm8hLW9fZuW7DxbdZJ-mCQ2Ozd8A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 08:34:00AM -0800, Andy Lutomirski wrote:
> On Thu, Dec 14, 2017 at 8:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:

> >> > Can the PF_KTHREAD thing be its own patch so it can be reviewed on its own?
> >>
> >> I had that as a separate patch at some point.
> >
> > See 5/N
> 
> It looks like a little bit of it got mixed in to this patch, though.

I can fix that..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
