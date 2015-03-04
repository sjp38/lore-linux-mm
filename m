Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 847706B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 15:56:32 -0500 (EST)
Received: by widex7 with SMTP id ex7so33913323wid.4
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 12:56:32 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id ev14si8926278wjc.143.2015.03.04.12.56.30
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 12:56:31 -0800 (PST)
Date: Wed, 4 Mar 2015 22:56:14 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 03/24] mm: avoid PG_locked on tail pages
Message-ID: <20150304205614.GA19606@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1425486792-93161-4-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.11.1503041246470.23719@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1503041246470.23719@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 04, 2015 at 12:48:54PM -0600, Christoph Lameter wrote:
> On Wed, 4 Mar 2015, Kirill A. Shutemov wrote:
> 
> > index c851ff92d5b3..58b98bced299 100644
> > --- a/include/linux/page-flags.h
> > +++ b/include/linux/page-flags.h
> > @@ -207,7 +207,8 @@ static inline int __TestClearPage##uname(struct page *page) { return 0; }
> >
> >  struct page;	/* forward declaration */
> >
> > -TESTPAGEFLAG(Locked, locked)
> > +#define PageLocked(page) test_bit(PG_locked, &compound_head(page)->flags)
> > +
> >  PAGEFLAG(Error, error) TESTCLEARFLAG(Error, error)
> 
> Hmmm... Now one of the pageflag functions operates on the head page unlike
> the other pageflag functions that only operate on the flag indicated.
> 
> Given that pageflags provide a way to implement checks for head / tail
> pages this seems to be a bad idea.

I agree, I need to take more systematic look on page flags vs. compound
pages. I'll try to come up with something before the summit.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
