Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 749386B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 22:02:59 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id av4so1153218igc.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 19:02:59 -0800 (PST)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id i123si8499550ioi.135.2016.03.10.19.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 10 Mar 2016 19:02:58 -0800 (PST)
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 11 Mar 2016 13:02:53 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 4CD072BB0054
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 14:02:47 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2B32c2m66519132
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 14:02:47 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2B32EJF018510
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 14:02:14 +1100
Message-ID: <56E23523.4020201@linux.vnet.ibm.com>
Date: Fri, 11 Mar 2016 08:31:55 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/9] mm/hugetlb: Make GENERAL_HUGETLB functions PGD implementation
 aware
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, aneesh.kumar@linux.vnet.ibm.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 03/09/2016 05:40 PM, Anshuman Khandual wrote:
> Currently both the ARCH_WANT_GENERAL_HUGETLB functions 'huge_pte_alloc'
> and 'huge_pte_offset' dont take into account huge page implementation
> at the PGD level. With addition of PGD awareness into these functions,
> more architectures like POWER which also implements huge pages at PGD
> level (along with PMD level), can use ARCH_WANT_GENERAL_HUGETLB option.

Hugh/Mel/Naoya/Andrew,

	Thoughts/inputs/suggestions ? Does this change looks okay ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
