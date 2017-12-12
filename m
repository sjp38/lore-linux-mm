Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E58D26B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 17:25:53 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y200so908299itc.7
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 14:25:53 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n83si146955ioi.76.2017.12.12.14.25.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 14:25:52 -0800 (PST)
Date: Tue, 12 Dec 2017 23:25:16 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 13/16] x86/ldt: Introduce LDT write fault handler
Message-ID: <20171212222516.kt4xp4ec2weavbsz@hirez.programming.kicks-ass.net>
References: <20171212173221.496222173@linutronix.de>
 <20171212173334.345422294@linutronix.de>
 <CA+55aFwgGDa_JfZZPoaYtw5yE1oYnn1+0t51D=WU8a7__1Lauw@mail.gmail.com>
 <alpine.DEB.2.20.1712122017100.2289@nanos>
 <212680b8-6f8d-f785-42fd-61846553570d@intel.com>
 <alpine.DEB.2.20.1712122124320.2289@nanos>
 <alpine.DEB.2.20.1712122219580.2289@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1712122219580.2289@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 10:41:03PM +0100, Thomas Gleixner wrote:
> Now that made me go back to the state of the patch series which made us
> make that magic 'touch' and write fault handler. The difference to the code
> today is that it did not prepopulate the user visible mapping.
> 
> We added that later because we were worried about not being able to
> populate it in the #PF due to memory pressure without ripping out the magic
> cure again.
> 
> But I did now and actually removing both the user exit magic 'touch' code
> and the write fault handler keeps it working.

Argh, had we really not tried that!? Bah.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
