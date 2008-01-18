Date: Fri, 18 Jan 2008 19:04:31 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [patch 2/6] mm: introduce pte_special pte bit
Message-ID: <20080118180431.GA19591@uranus.ravnborg.org>
References: <20080118045649.334391000@suse.de> <20080118045755.516986000@suse.de> <alpine.LFD.1.00.0801180816120.2957@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.00.0801180816120.2957@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 18, 2008 at 08:41:22AM -0800, Linus Torvalds wrote:
> 
> 
> On Fri, 18 Jan 2008, npiggin@suse.de wrote:
> >   */
> > +#ifdef __HAVE_ARCH_PTE_SPECIAL
> > +# define HAVE_PTE_SPECIAL 1
> > +#else
> > +# define HAVE_PTE_SPECIAL 0
> > +#endif
> >  struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr, pte_t pte)
> >  {
> > -	unsigned long pfn = pte_pfn(pte);
> > +	unsigned long pfn;
> > +
> > +	if (HAVE_PTE_SPECIAL) {
> 
> I really don't think this is *any* different from "#ifdefs in code".

One fundamental difference is that with the above syntax we always
compile both versions of the code - so we do not end up with one
version that builds and another version that dont.

This has always striked me as a good reason to do the above and
I think it is busybox that does so with success.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
