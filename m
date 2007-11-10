Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id lAA1Y9Wp003905
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 17:34:09 -0800
Received: from rv-out-0910.google.com (rvbg11.prod.google.com [10.140.83.11])
	by zps35.corp.google.com with ESMTP id lAA1Y9UL010204
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 17:34:09 -0800
Received: by rv-out-0910.google.com with SMTP id g11so590121rvb
        for <linux-mm@kvack.org>; Fri, 09 Nov 2007 17:34:08 -0800 (PST)
Message-ID: <b040c32a0711091734s13d4ffcaj4123dd27d24bf330@mail.gmail.com>
Date: Fri, 9 Nov 2007 17:34:08 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] hugetlb: fix i_blocks accounting
In-Reply-To: <20071109171613.3b11b581.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0711082343t2b94b495r1608d99ec0e28a4c@mail.gmail.com>
	 <1194617837.14675.45.camel@localhost.localdomain>
	 <b040c32a0711090942x45e89356kcc7d3282b2dedcb2@mail.gmail.com>
	 <1194631797.14675.49.camel@localhost.localdomain>
	 <20071109171613.3b11b581.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aglitke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Nov 9, 2007 5:16 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 09 Nov 2007 12:09:57 -0600
> aglitke <agl@us.ibm.com> wrote:
>
> > Thanks for that explanation.  It makes complete sense to me now.
>
> We have a distressing number of hugetlb patches here:
>
> hugetlb-follow_hugetlb_page-for-write-access.patch
> hugetlb-allow-sticky-directory-mount-option.patch
> hugetlb-split-alloc_huge_page-into-private-and-shared-components.patch
> hugetlb-split-alloc_huge_page-into-private-and-shared-components-checkpatch-fixes.patch
> hugetlb-fix-quota-management-for-private-mappings.patch
> hugetlb-debit-quota-in-alloc_huge_page.patch
> hugetlb-allow-bulk-updating-in-hugetlb__quota.patch
> hugetlb-enforce-quotas-during-reservation-for-shared-mappings.patch
> mm-hugetlbc-make-a-function-static.patch
> hugetlb-fix-i_blocks-accounting.patch
>
> (all available at http://userweb.kernel.org/~akpm/mmotm/)
>
> Could we please put heads together and work out which of these need to go
> into 2.6.24?  And 2.6.23, come to that...

I would vote all of it.  If we really need to prioritize them, I would
list them in the following order:

1. fs quota fix:
   hugetlb-split-alloc_huge_page-into-private-and-shared-components.patch
   hugetlb-split-alloc_huge_page-into-private-and-shared-components-checkpatch-fixes.patch
   hugetlb-fix-quota-management-for-private-mappings.patch
   hugetlb-debit-quota-in-alloc_huge_page.patch
   hugetlb-allow-bulk-updating-in-hugetlb__quota.patch
   hugetlb-enforce-quotas-during-reservation-for-shared-mappings.patch

2. i_blocks accounting
   hugetlb-fix-i_blocks-accounting.patch

3. follow_hugetlb_page (this is a rather nasty bug, I'm glad we
haven't hit it in real world.  Or maybe Adam did, and hence the
patch?).
   hugetlb-follow_hugetlb_page-for-write-access.patch

4. others (these are really simple single line low risk patches, why not?)
   hugetlb-allow-sticky-directory-mount-option.patch
   mm-hugetlbc-make-a-function-static.patch

oh, there are more bugs in hugetlb: sys_mincore isn't working on
hugetlb range.  I guess that can wait for 2.6.25.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
