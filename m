Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3266B006C
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 08:09:10 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so102867665wib.1
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 05:09:10 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id eh6si9039849wib.92.2015.04.02.05.09.08
        for <linux-mm@kvack.org>;
        Thu, 02 Apr 2015 05:09:08 -0700 (PDT)
Date: Thu, 2 Apr 2015 15:09:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: get page_cache_get_speculative() work on tail pages
Message-ID: <20150402120905.GD24028@node.dhcp.inet.fi>
References: <1427928772-100068-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1504011617300.6431@eggly.anvils>
 <20150401235651.GA20597@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1504011705310.6939@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1504011705310.6939@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Steve Capper <steve.capper@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Apr 01, 2015 at 05:08:53PM -0700, Hugh Dickins wrote:
> On Thu, 2 Apr 2015, Kirill A. Shutemov wrote:
> > On Wed, Apr 01, 2015 at 04:21:30PM -0700, Hugh Dickins wrote:
> > > On Thu, 2 Apr 2015, Kirill A. Shutemov wrote:
> > > 
> > > > Generic RCU fast GUP rely on page_cache_get_speculative() to obtain pin
> > > > on pte-mapped page.  As pointed by Aneesh during review of my compound
> > > > pages refcounting rework, page_cache_get_speculative() would fail on
> > > > pte-mapped tail page, since tail pages always have page->_count == 0.
> > > > 
> > > > That means we would never be able to successfully obtain pin on
> > > > pte-mapped tail page via generic RCU fast GUP.
> > > > 
> > > > But the problem is not exclusive to my patchset. In current kernel some
> > > > drivers (sound, for instance) already map compound pages with PTEs.
> > > 
> > > Hah, you were sending this as I was replying to the original thread.
> > > 
> > > Do we care if fast gup fails on some hardware driver's compound pages?
> > > I don't think we do, and it would be better not to complicate the
> > > low-level page_cache_get_speculative for them.
> > 
> > Fair enough :-/
> > 
> > I'll check tomorrow if it will look more reasonable on gup_pte_range()
> > level, rather than page_cache_get_speculative().
> 
> But we don't need it on the (fast) gup_pte_range() level either, do we?
> Or do you have THP changes in mmotm which are now demanding this?

No. I'll keep it local to my patchset.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
