Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id A6CC56B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 09:26:55 -0400 (EDT)
Received: by wixm2 with SMTP id m2so35641963wix.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 06:26:55 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id dg1si4001080wib.3.2015.04.01.06.26.53
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 06:26:54 -0700 (PDT)
Date: Wed, 1 Apr 2015 16:26:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 00/24] THP refcounting redesign
Message-ID: <20150401132642.GA17798@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <87ego6lchy.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ego6lchy.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 30, 2015 at 09:10:41PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > Hello everybody,
> >
> > It's bug-fix update of my thp refcounting work.
> >
> > The goal of patchset is to make refcounting on THP pages cheaper with
> > simpler semantics and allow the same THP compound page to be mapped with
> > PMD and PTEs. This is required to get reasonable THP-pagecache
> > implementation.
> >
> > With the new refcounting design it's much easier to protect against
> > split_huge_page(): simple reference on a page will make you the deal.
> > It makes gup_fast() implementation simpler and doesn't require
> > special-case in futex code to handle tail THP pages.
> >
> > It should improve THP utilization over the system since splitting THP in
> > one process doesn't necessary lead to splitting the page in all other
> > processes have the page mapped.
> 
> Can we split this series into two. The compound_lock removal and using
> migration entries ro freeze page count can be made into a seperate
> series ?

I would problaby move these patchse to the end of patchset. So they can be
applied separately.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
