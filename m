Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79B2D6B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 09:35:10 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p17so293002pfh.18
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 06:35:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i70si172587pgc.36.2017.12.05.06.35.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 06:35:09 -0800 (PST)
Date: Tue, 5 Dec 2017 15:34:53 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [patch 28/60] x86/mm/kpti: Disable global pages if
 KERNEL_PAGE_TABLE_ISOLATION=y
Message-ID: <20171205143453.asr5hyk33me73ana@pd.tnic>
References: <20171204140706.296109558@linutronix.de>
 <20171204150607.150578521@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171204150607.150578521@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, richard.fellner@student.tugraz.at, michael.schwarz@iaik.tugraz.at

On Mon, Dec 04, 2017 at 03:07:34PM +0100, Thomas Gleixner wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Global pages stay in the TLB across context switches.  Since all contexts
> share the same kernel mapping, these mappings are marked as global pages
> so kernel entries in the TLB are not flushed out on a context switch.
> 
> But, even having these entries in the TLB opens up something that an
> attacker can use, such as the double-page-fault attack:
> 
>    http://www.ieee-security.org/TC/SP2013/papers/4977a191.pdf
> 
> That means that even when KERNEL_PAGE_TABLE_ISOLATION switches page tables
> on return to user space the global pages would stay in the TLB cache.
> 
> Disable global pages so that kernel TLB entries can be flushed before
> returning to user space. This way, all accesses to kernel addresses from
> userspace result in a TLB miss independent of the existence of a kernel
> mapping.
> 
> Supress global pages via the __supported_pte_mask. The user space

"Suppress"

Otherwise

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
