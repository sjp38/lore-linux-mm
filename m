Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 783486B026E
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:25:55 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id z142so401728itc.6
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:25:55 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id g9si133248itg.95.2017.12.12.10.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 10:25:54 -0800 (PST)
Date: Tue, 12 Dec 2017 19:25:37 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Message-ID: <20171212182537.jfyoch3t2pe2sds4@hirez.programming.kicks-ass.net>
References: <20171212173221.496222173@linutronix.de>
 <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171212180509.iewpmzdhvsusk2nk@hirez.programming.kicks-ass.net>
 <CALCETrXTYY2oDSNXapFPX5z=dgZ5ievemoxupO6uD_88h5b90A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXTYY2oDSNXapFPX5z=dgZ5ievemoxupO6uD_88h5b90A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 10:06:51AM -0800, Andy Lutomirski wrote:
> On Tue, Dec 12, 2017 at 10:05 AM, Peter Zijlstra <peterz@infradead.org> wrote:

> > gup would find the page. These patches do in fact rely on that through
> > the populate things.
> >
> 
> Blech.  So you can write(2) from the LDT to a file and you can even
> sendfile it, perhaps. 

Hmm, indeed.. I suppose I could go fix that. But how bad is it to leak
the LDT contents?

What would be far worse of course is if we could read(2) data into the
ldt, I'll look into that.

> What happens if it's get_user_page()'d when
> modify_ldt() wants to free it?

modify_ldt should never free pages, we only ever free pages when we
destroy the mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
