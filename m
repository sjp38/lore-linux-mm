From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Mon, 30 May 2005 15:16:07 +1000
Subject: Re: PTI: clean page table interface
Message-ID: <20050530051607.GA20379@cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU> <20050528085327.GA19047@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050528085327.GA19047@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 28/05/05 09:53 +0100, Christoph Hellwig wrote:
> I've not looked over it a lot, but your code organization is a bit odd
> and non-standard:
> 
>  - generic implementations for per-arch abstractions go into asm-generic
>    and every asm-foo/ header that wants to use it includes it.  In your
>    case that would be an asm-generic/page_table.h for the generic 3level
>    page tables.  Please avoid #includes for generic implementations from
>    architecture-independent headers guarded by CONFIG_ symbols.
>  - I don't think the subdirectory under mm/ makes sense.  Just call the
>    file mm/3level-page-table.c or something.
>  - similar please avoid the include/mm directory.  It might or might not
>    make sense to have a subdirectory for mm headers, but please don't
>    star one as part of a large patch series.

Thank you for your pointers regarding the code organisation.  I will be
taking your advice which will appear in the next iteration of patches.

We have a guarded page table implementation at UNSW (originally conceived
of by Jochen Liedtke).  We are testing it in Linux as an alternative to
the MLPT.  After the current patches (to achieve a clean interface), we have
a GPT patch set which includes directories mm/fixed-mlpt and mm/gpt.

The GPT is far more sophisticated than the MLPT and is written across a
number of files.  Having a directory for each page table implementation
makes sense when you see alternate page tables side by side.

I am writing a patch[0/15] to give a brief explanation of what we are doing
at UNSW and to explain the interface a little better.  

Please let me know if there is anything else that would assist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
