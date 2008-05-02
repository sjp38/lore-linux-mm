Date: Fri, 2 May 2008 03:48:59 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB v2
Message-ID: <20080502014858.GB11844@wotan.suse.de>
References: <20080410193137.GB9482@wotan.suse.de> <20080415034407.GA9120@ubuntu> <20080501015418.GC15179@wotan.suse.de> <Pine.LNX.4.64.0805011226410.8738@schroedinger.engr.sgi.com> <20080502004325.GA30768@wotan.suse.de> <Pine.LNX.4.64.0805011813180.13527@schroedinger.engr.sgi.com> <20080502012321.GE30768@wotan.suse.de> <Pine.LNX.4.64.0805011825420.13697@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805011825420.13697@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Ahmed S. Darwish" <darwish.07@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 01, 2008 at 06:28:57PM -0700, Christoph Lameter wrote:
> On Fri, 2 May 2008, Nick Piggin wrote:
> 
> > But overloading struct page values happens in other places too. Putting
> > everything into struct page is not scalable. We could also make kmalloc
> 
> Well lets at least attempt to catch the biggest users.

You want to also put slab and slob in there? What about page allocator?
It is ridiculous for the sake of "being easy to inspect with debuggers".
How hard is (struct slub_page *) to type?

Here is a real benefit you get with clearly defined types for struct
page: type checking.


> Also makes code 
> clearer if you f.e. use page->first_page instead of page->private for 
> compound pages.

compound_page_head() is fine too.

 
> kmalloc is intended to return an arbitrary type. struct page has a defined 
> format that needs to be respected.

So does kmalloc if you take the union of all types it might possibly
be used as.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
