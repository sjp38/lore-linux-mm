Date: Fri, 21 Apr 2006 09:43:45 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/5] mm: remap_vmalloc_range
Message-ID: <20060421074345.GN21660@wotan.suse.de>
References: <20060301045901.12434.54077.sendpatchset@linux.site> <20060301045910.12434.4844.sendpatchset@linux.site> <20060421002938.3878aec5.akpm@osdl.org> <20060421074156.GM21660@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060421074156.GM21660@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 21, 2006 at 09:41:57AM +0200, Nick Piggin wrote:
> On Fri, Apr 21, 2006 at 12:29:38AM -0700, Andrew Morton wrote:
> > 
> > When replacing calls to remap_pfn_rage() with calls to remap_valloc_range():
> > 
> > - remap_pfn_range() sets VM_IO|VM_RESERVED|VM_PFNMAP on the user's vma. 
> >   remap_valloc_range() sets only VM_RESERVED.
> 
> Yep, it doesn't use PFNMAPs (we can always user the underlying struct
>  page), nor is it IO space. The only change that should be seen, as
> noted in patch 4/5, is that get_user_pages will work on all mappings
> now. I don't think there is a downside to this?

By "change that should be seen", I mean the only change that
userspace should see.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
