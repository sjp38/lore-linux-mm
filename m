Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 141506B0036
	for <linux-mm@kvack.org>; Sun, 18 May 2014 23:22:00 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so5124553pad.4
        for <linux-mm@kvack.org>; Sun, 18 May 2014 20:21:59 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id lp7si17703509pab.189.2014.05.18.20.21.57
        for <linux-mm@kvack.org>;
        Sun, 18 May 2014 20:21:58 -0700 (PDT)
Date: Mon, 19 May 2014 12:24:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6] mm: support madvise(MADV_FREE)
Message-ID: <20140519032441.GB13248@bbox>
References: <1399857988-2880-1-git-send-email-minchan@kernel.org>
 <20140515154657.GA2720@cmpxchg.org>
 <20140516063427.GC27599@bbox>
 <20140516193800.GA7273@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140516193800.GA7273@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, John Stultz <john.stultz@linaro.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>

On Fri, May 16, 2014 at 10:38:00PM +0300, Kirill A. Shutemov wrote:
> On Fri, May 16, 2014 at 03:34:27PM +0900, Minchan Kim wrote:
> > > > +static inline unsigned long lazyfree_pmd_range(struct mmu_gather *tlb,
> > > > +				struct vm_area_struct *vma, pud_t *pud,
> > > > +				unsigned long addr, unsigned long end)
> > > > +{
> > > > +	pmd_t *pmd;
> > > > +	unsigned long next;
> > > > +
> > > > +	pmd = pmd_offset(pud, addr);
> > > > +	do {
> > > > +		next = pmd_addr_end(addr, end);
> > > > +		if (pmd_trans_huge(*pmd))
> > > > +			split_huge_page_pmd(vma, addr, pmd);
> > > 
> > > /* XXX */ as well? :)
> > 
> > You meant huge page unit lazyfree rather than 4K page unit?
> > If so, I will add.
> 
> Please, free huge page if range cover it. 


Yeb, We could do further patches if current patch's design is done
from reviewers.

Thanks.

> 
> -- 
>  Kirill A. Shutemov
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
