Date: Wed, 6 Jun 2007 17:44:07 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 4/4] mm: variable length argument support
Message-ID: <20070606084407.GA9975@linux-sh.org>
References: <20070605150523.786600000@chello.nl> <20070605151203.790585000@chello.nl> <20070606013658.20bcbe2f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070606013658.20bcbe2f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 06, 2007 at 01:36:58AM -0700, Andrew Morton wrote:
> On Tue, 05 Jun 2007 17:05:27 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > From: Ollie Wild <aaw@google.com>
> > 
> > Remove the arg+env limit of MAX_ARG_PAGES by copying the strings directly
> > from the old mm into the new mm.
> > 
> > We create the new mm before the binfmt code runs, and place the new stack
> > at the very top of the address space. Once the binfmt code runs and figures
> > out where the stack should be, we move it downwards.
> > 
> > It is a bit peculiar in that we have one task with two mm's, one of which is
> > inactive.
> > 
> > ...
> >
> > +				flush_cache_page(bprm->vma, kpos,
> > +						 page_to_pfn(kmapped_page));
> 
> Breaks SuperH:
> 
> fs/exec.c: In function `bprm_mm_init':
> fs/exec.c:268: warning: unused variable `vma'
> fs/exec.c: In function `copy_strings':
> fs/exec.c:431: error: structure has no member named `vma'
> 
More pointedly, bprm->vma doesn't exist if CONFIG_MMU=n, which Andrew's
config seems to have ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
