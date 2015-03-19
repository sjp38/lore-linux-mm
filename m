Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 47111900015
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:11:01 -0400 (EDT)
Received: by webcq43 with SMTP id cq43so62774581web.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:11:00 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id li2si3161126wjc.161.2015.03.19.10.10.59
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:10:59 -0700 (PDT)
Date: Thu, 19 Mar 2015 19:10:43 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 00/24] THP refcounting redesign
Message-ID: <20150319171043.GA10658@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <8761a0arki.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8761a0arki.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 17, 2015 at 03:12:05PM +0530, Aneesh Kumar K.V wrote:
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
> I tested this patch on ppc64 and verified thp allocation and split.
> I also checked the subpage_prot and it worked as expected. I will
> run more tests with this series and update if I find any issues.

Thanks a lot.

Could you also prepare patch to drop power-specific code related to
pmd_trans_splitting()? It's not needed anymore with the patchset.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
