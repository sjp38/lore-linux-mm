Date: Fri, 21 Apr 2006 01:02:44 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/5] mm: remap_vmalloc_range
Message-Id: <20060421010244.2f36821c.akpm@osdl.org>
In-Reply-To: <20060421074156.GM21660@wotan.suse.de>
References: <20060301045901.12434.54077.sendpatchset@linux.site>
	<20060301045910.12434.4844.sendpatchset@linux.site>
	<20060421002938.3878aec5.akpm@osdl.org>
	<20060421074156.GM21660@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> wrote:
>
> > 
> > - are vma->vm_start and vma->vm_end always a multiple of PAGE_SIZE?  (I
> >   always forget).  If not, remap_valloc_range() looks a tad buggy.
> 
> I hope so.

do_mmap_pgoff() seems to dtrt.  It makes one wonder why vm_start and vm_end
aren't in units of PAGE_SIZE.

> > 
> > - remap_valloc_range() would lose a whole buncha typecasts if you use the
> >   gcc pointer-arith-with-void* extension.
> 
> Should I?

Well it's a gccism, and a good one.  We have lots of gccisms and using this
one here will neaten things up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
