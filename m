Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2593C6B0036
	for <linux-mm@kvack.org>; Fri, 16 May 2014 15:38:38 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id q59so3087466wes.10
        for <linux-mm@kvack.org>; Fri, 16 May 2014 12:38:37 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id f41si2575586eeo.308.2014.05.16.12.38.36
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 12:38:36 -0700 (PDT)
Date: Fri, 16 May 2014 22:38:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v6] mm: support madvise(MADV_FREE)
Message-ID: <20140516193800.GA7273@node.dhcp.inet.fi>
References: <1399857988-2880-1-git-send-email-minchan@kernel.org>
 <20140515154657.GA2720@cmpxchg.org>
 <20140516063427.GC27599@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140516063427.GC27599@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, John Stultz <john.stultz@linaro.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>

On Fri, May 16, 2014 at 03:34:27PM +0900, Minchan Kim wrote:
> > > +static inline unsigned long lazyfree_pmd_range(struct mmu_gather *tlb,
> > > +				struct vm_area_struct *vma, pud_t *pud,
> > > +				unsigned long addr, unsigned long end)
> > > +{
> > > +	pmd_t *pmd;
> > > +	unsigned long next;
> > > +
> > > +	pmd = pmd_offset(pud, addr);
> > > +	do {
> > > +		next = pmd_addr_end(addr, end);
> > > +		if (pmd_trans_huge(*pmd))
> > > +			split_huge_page_pmd(vma, addr, pmd);
> > 
> > /* XXX */ as well? :)
> 
> You meant huge page unit lazyfree rather than 4K page unit?
> If so, I will add.

Please, free huge page if range cover it. 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
