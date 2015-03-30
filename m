Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 225EF6B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 11:21:09 -0400 (EDT)
Received: by wgbdm7 with SMTP id dm7so72762658wgb.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 08:21:08 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id p18si18648907wjw.18.2015.03.30.08.21.06
        for <linux-mm@kvack.org>;
        Mon, 30 Mar 2015 08:21:07 -0700 (PDT)
Date: Mon, 30 Mar 2015 18:20:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 18/24] thp, mm: split_huge_page(): caller need to lock
 page
Message-ID: <20150330152051.GA5849@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1425486792-93161-19-git-send-email-kirill.shutemov@linux.intel.com>
 <87mw2ulgoa.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mw2ulgoa.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 30, 2015 at 07:40:29PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > We're going to use migration entries instead of compound_lock() to
> > stabilize page refcounts. Setup and remove migration entries require
> > page to be locked.
> >
> > Some of split_huge_page() callers already have the page locked. Let's
> > require everybody to lock the page before calling split_huge_page().
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Why not have split_huge_page_locked/unlocked, and call the one which
> takes lock internally every where ?

We could do that, but it's not obvoius for me what is benefit. Couple of
lines on caller side?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
