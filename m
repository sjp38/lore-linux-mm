Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BA7146B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 17:57:30 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 124so52563417pfg.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 14:57:30 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id sk8si1205938pac.44.2016.03.09.14.57.29
        for <linux-mm@kvack.org>;
        Wed, 09 Mar 2016 14:57:29 -0800 (PST)
Subject: Re: [RFC 5/9] powerpc/mm: Split huge_pte_offset function for BOOK3S
 64K
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1457525450-4262-5-git-send-email-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56E0AA59.4030905@intel.com>
Date: Wed, 9 Mar 2016 14:57:29 -0800
MIME-Version: 1.0
In-Reply-To: <1457525450-4262-5-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

On 03/09/2016 04:10 AM, Anshuman Khandual wrote:
> Currently the 'huge_pte_offset' function has only one version for
> all the configuations and platforms. This change splits the function
> into two versions, one for 64K page size based BOOK3S implementation
> and the other one for everything else. This change is also one of the
> prerequisites towards enabling GENERAL_HUGETLB implementation for
> BOOK3S 64K based huge pages.

I think there's a bit of background missing here for random folks on
linux-mm to make sense of these patches.

What is BOOK3S and what does it mean for these patches?  Why is its 64K
page size implementation different than all the others?  Is there a 4K
page size BOOK3S?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
