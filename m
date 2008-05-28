Date: Wed, 28 May 2008 10:49:10 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 23/23] powerpc: support multiple hugepage sizes
Message-ID: <20080528084910.GB2630@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143454.559452000@nick.local0.net> <20080527171403.GI20709@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080527171403.GI20709@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Jon Tollefson <kniht@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 27, 2008 at 10:14:03AM -0700, Nishanth Aravamudan wrote:
> On 26.05.2008 [00:23:40 +1000], npiggin@suse.de wrote:
> > Instead of using the variable mmu_huge_psize to keep track of the huge
> > page size we use an array of MMU_PAGE_* values.  For each supported
> > huge page size we need to know the hugepte_shift value and have a
> > pgtable_cache.  The hstate or an mmu_huge_psizes index is passed to
> > functions so that they know which huge page size they should use.
> > 
> > The hugepage sizes 16M and 64K are setup(if available on the
> > hardware) so that they don't have to be set on the boot cmd line in
> > order to use them.  The number of 16G pages have to be specified at
> > boot-time though (e.g. hugepagesz=16G hugepages=5).
> 
> This patch probably should updated Documentation as well, to indicate
> power can also specify hugepagesz multiple times?

OK, added a small bit to it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
