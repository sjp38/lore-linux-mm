Date: Mon, 2 Apr 2007 16:00:51 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [SLUB 2/2] i386 arch page size slab fixes
Message-ID: <20070402230051.GI2986@holomorphy.com>
References: <20070331193056.1800.68058.sendpatchset@schroedinger.engr.sgi.com> <20070331193107.1800.28259.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070331193107.1800.28259.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Sat, Mar 31, 2007 at 11:31:07AM -0800, Christoph Lameter wrote:
> Patch by William Irwin with only very minor modifications by me which are
> 1. Removal of HIGHMEM64G slab caches. It seems that virtualization hosts
>    require a a full pgd page.

The HIGHMEM64G slab allocations are meaningfully performant vs.
page-sized allocations where virtualization is absent. I would
personally rather whip Xen into shape enough to be able to handle the
minimal pgd allocations than retain the oversized pgd allocations even
in only the Xen case. Also, the entire unshared kernel pmd shenanigan
in Xen is an artifact of its recursive pagetable affair, which can also
be done away with a SMOP.


On Sat, Mar 31, 2007 at 11:31:07AM -0800, Christoph Lameter wrote:
> 2. Add missing virtualization hook. Seems that we need a new way
>    of serializing paravirt_alloc(). It may need to do its own serialization.
> 3. Remove ARCH_USES_SLAB_PAGE_STRUCT

This doesn't quite cover all bases. The changes to pageattr.c and
fault.c are dubious and need verification at the very least. They were
largely slapped together to get the files past the compiler for the
performance comparisons that were never properly done.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
