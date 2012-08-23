Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 851E16B0070
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 13:36:07 -0400 (EDT)
Date: Thu, 23 Aug 2012 18:36:02 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2] mm: hugetlb: add arch hook for clearing page flags
 before entering pool
Message-ID: <20120823173602.GA3117@mudshark.cambridge.arm.com>
References: <1345739833-25008-1-git-send-email-will.deacon@arm.com>
 <20120823171156.GE19968@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120823171156.GE19968@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Thu, Aug 23, 2012 at 06:11:56PM +0100, Michal Hocko wrote:
> On Thu 23-08-12 17:37:13, Will Deacon wrote:
> > The core page allocator ensures that page flags are zeroed when freeing
> > pages via free_pages_check. A number of architectures (ARM, PPC, MIPS)
> > rely on this property to treat new pages as dirty with respect to the
> > data cache and perform the appropriate flushing before mapping the pages
> > into userspace.
> > 
> > This can lead to cache synchronisation problems when using hugepages,
> > since the allocator keeps its own pool of pages above the usual page
> > allocator and does not reset the page flags when freeing a page into
> > the pool.
> > 
> > This patch adds a new architecture hook, arch_clear_hugepage_flags, so
> > that architectures which rely on the page flags being in a particular
> > state for fresh allocations can adjust the flags accordingly when a
> > page is freed into the pool.
> > 
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> 
> Looks good to me
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Cheers Michal. Next step: start posting the ARM code!

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
