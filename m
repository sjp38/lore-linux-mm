Date: Fri, 2 May 2008 03:23:22 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB v2
Message-ID: <20080502012321.GE30768@wotan.suse.de>
References: <20080410193137.GB9482@wotan.suse.de> <20080415034407.GA9120@ubuntu> <20080501015418.GC15179@wotan.suse.de> <Pine.LNX.4.64.0805011226410.8738@schroedinger.engr.sgi.com> <20080502004325.GA30768@wotan.suse.de> <Pine.LNX.4.64.0805011813180.13527@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805011813180.13527@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Ahmed S. Darwish" <darwish.07@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 01, 2008 at 06:14:52PM -0700, Christoph Lameter wrote:
> On Fri, 2 May 2008, Nick Piggin wrote:
> 
> > If you are not debugging sl?b.c code/pages, then why would you want to see
> > what those fields are?
> 
> Because you are f.e. inspecting a core dump and want to see why certain 
> fields have certain values to verify that the structures were not 
> overwrittten or corrupted etc.

But overloading struct page values happens in other places too. Putting
everything into struct page is not scalable. We could also make kmalloc
return not a void pointer put a pointer to a union of every possible
structure that kmalloc may ever be used for, just in case we have to
inspect some data structure that could have been overwritten by something
else ;)

But seriously... you can always cast a page to a slub_page to see if it is
unexpectedly a slub page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
