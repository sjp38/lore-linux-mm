Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id CFC976B007E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 16:29:24 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id n5so105060041pfn.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 13:29:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ui8si9132597pab.38.2016.03.14.13.29.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 13:29:23 -0700 (PDT)
Date: Mon, 14 Mar 2016 13:29:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 1/9] mm/hugetlb: Make GENERAL_HUGETLB functions PGD
 implementation aware
Message-Id: <20160314132922.b2297b2b486416e4980741ee@linux-foundation.org>
In-Reply-To: <56E23523.4020201@linux.vnet.ibm.com>
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
	<56E23523.4020201@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, hughd@google.com, aneesh.kumar@linux.vnet.ibm.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net

On Fri, 11 Mar 2016 08:31:55 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:

> On 03/09/2016 05:40 PM, Anshuman Khandual wrote:
> > Currently both the ARCH_WANT_GENERAL_HUGETLB functions 'huge_pte_alloc'
> > and 'huge_pte_offset' dont take into account huge page implementation
> > at the PGD level. With addition of PGD awareness into these functions,
> > more architectures like POWER which also implements huge pages at PGD
> > level (along with PMD level), can use ARCH_WANT_GENERAL_HUGETLB option.
> 
> Hugh/Mel/Naoya/Andrew,
> 
> 	Thoughts/inputs/suggestions ? Does this change looks okay ?

Patches 1, 2 and 3 look OK to me.  Please include them in the powerpc
merge when the patchset is considered ready.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
