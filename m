Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id CE6126B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 22:48:43 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id n5so19640820pfn.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 19:48:43 -0800 (PST)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id l23si2847826pfj.53.2016.03.09.19.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 19:48:42 -0800 (PST)
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 10 Mar 2016 13:38:24 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id A98B32CE8059
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 14:38:19 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2A3cASj60424278
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 14:38:19 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2A3bksQ005534
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 14:37:46 +1100
Message-ID: <56E0EBF7.3040104@linux.vnet.ibm.com>
Date: Thu, 10 Mar 2016 09:07:27 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC 5/9] powerpc/mm: Split huge_pte_offset function for BOOK3S
 64K
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com> <1457525450-4262-5-git-send-email-khandual@linux.vnet.ibm.com> <56E0AA59.4030905@intel.com>
In-Reply-To: <56E0AA59.4030905@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, aneesh.kumar@linux.vnet.ibm.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 03/10/2016 04:27 AM, Dave Hansen wrote:
> On 03/09/2016 04:10 AM, Anshuman Khandual wrote:
>> > Currently the 'huge_pte_offset' function has only one version for
>> > all the configuations and platforms. This change splits the function
>> > into two versions, one for 64K page size based BOOK3S implementation
>> > and the other one for everything else. This change is also one of the
>> > prerequisites towards enabling GENERAL_HUGETLB implementation for
>> > BOOK3S 64K based huge pages.
> I think there's a bit of background missing here for random folks on
> linux-mm to make sense of these patches.
> 
> What is BOOK3S and what does it mean for these patches?  Why is its 64K

BOOK3S is the server type in powerpc family of processors which can support
multiple base page sizes like 64K and 4K.

> page size implementation different than all the others?  Is there a 4K
> page size BOOK3S?

It supports huge pages of size 16M as well as 16G and their implementations
are different with respect to base page sizes of 64K and 4K.

Patches 1, 2 and 3 are generic VM changes and the rest are powerpc specific
changes. Should I have split them accordingly and send out differently for
generic and powerpc specific reviews ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
