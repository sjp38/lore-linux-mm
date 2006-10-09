From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: User switchable HW mappings & cie
Date: Mon, 9 Oct 2006 20:36:47 +0200
References: <1160347065.5926.52.camel@localhost.localdomain> <452A35FF.50009@tungstengraphics.com> <1160394662.10229.30.camel@localhost.localdomain>
In-Reply-To: <1160394662.10229.30.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200610092036.50010.ioe-lkml@rameria.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Thomas =?iso-8859-15?q?Hellstr=F6m?= <thomas@tungstengraphics.com>, linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>, Arnd Bergmann <arnd@arndb.de>, Linus Torvalds <torvalds@osdl.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi all,

On Monday, 9. October 2006 13:51, Benjamin Herrenschmidt wrote:
> > One problem that occurs is that the rule for ptes with non-backing 
> > struct pages
> > Which I think was introduced in 2.6.16:
> > 
> >     pfn_of_page == vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT)
> > 
> > cannot be honored, at least not with the DRM memory manager, since the 
> > graphics object will be associated with a vma and not the underlying 
> > physical address. User space will have vma->vm_pgoff as a handle to the 
> > object, which may move around in graphics memory.
> 
> That's a problem with VM_PFNMAP set indeed. get_user_pages() is a
> non-issue with VM_IO set too but I'm not sure about other code path that
> might try to hit here... though I think we don't hit that if MAP_SHARED,
> Nick ?

Istn't this just a non-linear PFN mapping, you are describing here?

Nick: 
	Cant your new fault consolidation code handle that?
	AFAICS your new .fault handler just gets the
	vma and pgoff and install the matching PTE via install_THINGIE()
	or vm_insert_THINGIE()

Or do I miss sth. here?


Regards

Ingo Oeser

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
