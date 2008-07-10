Date: Thu, 10 Jul 2008 10:57:30 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] - Map UV chipset space - pagetable
Message-ID: <20080710085730.GC19918@elte.hu>
References: <20080701194532.GA28405@sgi.com> <20080710013533.e059f556.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080710013533.e059f556.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jack Steiner <steiner@sgi.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 1 Jul 2008 14:45:32 -0500 Jack Steiner <steiner@sgi.com> wrote:
> 
> > +	BUG_ON((phys & ~PMD_MASK) || (size & ~PMD_MASK));
> 
> BUG_ON(A || B) is usually a bad idea.  If it goes bang, you'll really wish
> that it had been
> 
> 	BUG_ON(A);
> 	BUG_ON(B);

if you check how it's used:

+       init_extra_mapping_uc(UV_GLOBAL_MMR32_BASE, UV_GLOBAL_MMR32_SIZE);
+       init_extra_mapping_uc(UV_LOCAL_MMR_BASE, UV_LOCAL_MMR_SIZE);

those base/size pairs are really supposed to be aligned on 2MB. I.e. 
this is a really 'impossible' scenario that is not really driven by any 
external factor (hw or driver detail) and a compact check for it is 
acceptable too.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
