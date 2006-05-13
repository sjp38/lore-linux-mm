Date: Sat, 13 May 2006 15:54:43 -0700
From: Valerie Henson <val_henson@linux.intel.com>
Subject: Re: [patch 00/14] remap_file_pages protection support
Message-ID: <20060513225442.GE9612@goober>
References: <20060430172953.409399000@zion.home.lan> <4456D5ED.2040202@yahoo.com.au> <200605030225.54598.blaisorblade@yahoo.it> <445CC949.7050900@redhat.com> <445D75EB.5030909@yahoo.com.au> <4465E981.60302@yahoo.com.au> <20060513181945.GC9612@goober>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060513181945.GC9612@goober>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ulrich Drepper <drepper@redhat.com>, Blaisorblade <blaisorblade@yahoo.it>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Sat, May 13, 2006 at 11:19:46AM -0700, Valerie Henson wrote:
> The original program mmapped everything with the same permissions and
> no alignment restrictions, so all the mmaps were coalesced into one.
> This version alternates PROT_WRITE permissions on the mmap'd areas
> after they are written, so you get lots of vma's:

... Which is of course exactly the case that Blaisorblade's patches
should coalesce into one vma.  So I wrote another option which uses
holes instead - takes more memory initially, unfortunately.  Grab it
from:

http://www.nmt.edu/~val/patches/ebizzy.tar.gz

-p for preventing coaelescing via protections, -P for preventing via
holes.

-VAL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
