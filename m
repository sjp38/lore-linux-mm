Date: Fri, 9 Nov 2007 17:16:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] hugetlb: fix i_blocks accounting
Message-Id: <20071109171613.3b11b581.akpm@linux-foundation.org>
In-Reply-To: <1194631797.14675.49.camel@localhost.localdomain>
References: <b040c32a0711082343t2b94b495r1608d99ec0e28a4c@mail.gmail.com>
	<1194617837.14675.45.camel@localhost.localdomain>
	<b040c32a0711090942x45e89356kcc7d3282b2dedcb2@mail.gmail.com>
	<1194631797.14675.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: aglitke <agl@us.ibm.com>
Cc: kenchen@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 09 Nov 2007 12:09:57 -0600
aglitke <agl@us.ibm.com> wrote:

> Thanks for that explanation.  It makes complete sense to me now.

We have a distressing number of hugetlb patches here:

hugetlb-follow_hugetlb_page-for-write-access.patch
hugetlb-allow-sticky-directory-mount-option.patch
hugetlb-split-alloc_huge_page-into-private-and-shared-components.patch
hugetlb-split-alloc_huge_page-into-private-and-shared-components-checkpatch-fixes.patch
hugetlb-fix-quota-management-for-private-mappings.patch
hugetlb-debit-quota-in-alloc_huge_page.patch
hugetlb-allow-bulk-updating-in-hugetlb__quota.patch
hugetlb-enforce-quotas-during-reservation-for-shared-mappings.patch
mm-hugetlbc-make-a-function-static.patch
hugetlb-fix-i_blocks-accounting.patch

(all available at http://userweb.kernel.org/~akpm/mmotm/)

Could we please put heads together and work out which of these need to go
into 2.6.24?  And 2.6.23, come to that...

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
