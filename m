Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 799BC6B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 22:03:30 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id vs8so576740igb.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 19:03:30 -0800 (PST)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id 197si8485307ioe.191.2016.03.10.19.03.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 10 Mar 2016 19:03:29 -0800 (PST)
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 11 Mar 2016 13:03:25 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id E560E2CE8059
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 14:03:22 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2B33E5O3473776
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 14:03:22 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2B32ox8020040
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 14:02:50 +1100
Message-ID: <56E23547.2040303@linux.vnet.ibm.com>
Date: Fri, 11 Mar 2016 08:32:31 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/9] mm/hugetlb: Add follow_huge_pgd function
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com> <1457525450-4262-2-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1457525450-4262-2-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, aneesh.kumar@linux.vnet.ibm.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 03/09/2016 05:40 PM, Anshuman Khandual wrote:
> This just adds 'follow_huge_pgd' function which is will be used
> later in this series to make 'follow_page_mask' function aware
> of PGD based huge page implementation.

Hugh/Mel/Naoya/Andrew,

	Thoughts/inputs/suggestions ? Does this change looks okay ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
