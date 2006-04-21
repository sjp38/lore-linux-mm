Date: Fri, 21 Apr 2006 10:06:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/5] mm: remap_vmalloc_range
Message-ID: <20060421080638.GP21660@wotan.suse.de>
References: <20060301045901.12434.54077.sendpatchset@linux.site> <20060301045910.12434.4844.sendpatchset@linux.site> <20060421001712.4cd5625e.akpm@osdl.org> <20060421073315.GL21660@wotan.suse.de> <20060421005913.1c4322a2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060421005913.1c4322a2.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 21, 2006 at 12:59:13AM -0700, Andrew Morton wrote:
> Nick Piggin <npiggin@suse.de> wrote:
> > 
> > They should use vma->vm_page_prot?
> > 
> > The callers affected are the PAGE_SHARED ones (the others are unchanged).
> > Isn't it correct to provide readonly mappings if userspace asks for it?
> 
> Dunno.  I assume perfmon was using PAGE_READONLY because it doesn't want
> userspace altering the memory.  One would think that this should be
> enforced at mmap()-time, and that mprotect() might be able to override it
> anyway.  But I haven't looked that closely.

Oh yes definitely, and the perfmon case is OK, because it sets
PAGE_READONLY in ->vm_page_prot. About the mprotect issue -- I'm
not sure, this might be a problem for perfmon?

> First impression is that there's some potential for breaking stuff in all
> this - convince me otherwise ;)

Well, the PAGE_SHARED guys might break if userspace if they expect to be
able to write to readonly mappings. Unfortunate, but we could just put our
feet down and tell them to fix the code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
