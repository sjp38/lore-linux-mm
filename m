Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 364B86B0071
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 14:17:20 -0500 (EST)
Date: Thu, 21 Jan 2010 20:14:28 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 11 of 30] add pmd mangling functions to x86
Message-ID: <20100121191428.GH5598@random.random>
References: <patchbomb.1264054824@v2.random>
 <22367befceba0c312d15.1264054835@v2.random>
 <1264096076.32717.34496.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1264096076.32717.34496.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 21, 2010 at 09:47:56AM -0800, Dave Hansen wrote:
> On Thu, 2010-01-21 at 07:20 +0100, Andrea Arcangeli wrote:
> > @@ -351,7 +410,7 @@ static inline unsigned long pmd_page_vad
> >   * Currently stuck as a macro due to indirect forward reference to
> >   * linux/mmzone.h's __section_mem_map_addr() definition:
> >   */
> > -#define pmd_page(pmd)  pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT)
> > +#define pmd_page(pmd)  pfn_to_page((pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT)
> 
> Is there some new use of the high pmd bits or something?  I'm a bit
> confused why this is getting modified.

The NX bit is properly enabled on the huge pmd too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
