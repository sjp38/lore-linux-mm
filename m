Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id BE91E6B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 19:56:56 -0400 (EDT)
Received: by wixm2 with SMTP id m2so45481093wix.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 16:56:56 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id k6si6536674wif.35.2015.04.01.16.56.54
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 16:56:55 -0700 (PDT)
Date: Thu, 2 Apr 2015 02:56:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: get page_cache_get_speculative() work on tail pages
Message-ID: <20150401235651.GA20597@node.dhcp.inet.fi>
References: <1427928772-100068-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1504011617300.6431@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1504011617300.6431@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Steve Capper <steve.capper@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Apr 01, 2015 at 04:21:30PM -0700, Hugh Dickins wrote:
> On Thu, 2 Apr 2015, Kirill A. Shutemov wrote:
> 
> > Generic RCU fast GUP rely on page_cache_get_speculative() to obtain pin
> > on pte-mapped page.  As pointed by Aneesh during review of my compound
> > pages refcounting rework, page_cache_get_speculative() would fail on
> > pte-mapped tail page, since tail pages always have page->_count == 0.
> > 
> > That means we would never be able to successfully obtain pin on
> > pte-mapped tail page via generic RCU fast GUP.
> > 
> > But the problem is not exclusive to my patchset. In current kernel some
> > drivers (sound, for instance) already map compound pages with PTEs.
> 
> Hah, you were sending this as I was replying to the original thread.
> 
> Do we care if fast gup fails on some hardware driver's compound pages?
> I don't think we do, and it would be better not to complicate the
> low-level page_cache_get_speculative for them.

Fair enough :-/

I'll check tomorrow if it will look more reasonable on gup_pte_range()
level, rather than page_cache_get_speculative().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
