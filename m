Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2246B0253
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 14:04:33 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id y76so74208iod.1
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 11:04:33 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id b8si163586itc.152.2017.12.12.11.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 11:04:32 -0800 (PST)
Date: Tue, 12 Dec 2017 20:04:10 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 11/16] x86/ldt: Force access bit for CS/SS
Message-ID: <20171212190410.yhgc7xplx4hwem2n@hirez.programming.kicks-ass.net>
References: <20171212173221.496222173@linutronix.de>
 <20171212173334.176469949@linutronix.de>
 <CALCETrX+d+5COyWX1gDxi3gX93zFuq79UE+fhs27+ySq85j3+Q@mail.gmail.com>
 <20171212180918.lc5fdk5jyzwmrcxq@hirez.programming.kicks-ass.net>
 <CALCETrVmFSVqDGrH1K+Qv=svPTP3E6maVb5T2feyDNRkKfDVKA@mail.gmail.com>
 <C3141266-5522-4B5E-A0CE-65523F598F6D@amacapital.net>
 <20171212182906.cg635muwcdnh6p66@hirez.programming.kicks-ass.net>
 <alpine.DEB.2.20.1712121940230.2289@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1712121940230.2289@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@amacapital.net>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 07:41:39PM +0100, Thomas Gleixner wrote:
> The pages are populated _before_ the new ldt is installed. So no memory
> pressure issue, nothing. If the populate fails, then modify_ldt() returns
> with an error.

Also, these pages are not visible to reclaim. They're not pagecache and
we didn't install a shrinker.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
