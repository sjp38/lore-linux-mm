Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0516B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 22:03:16 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id fe3so65745492pab.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 19:03:16 -0800 (PST)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [125.16.236.4])
        by mx.google.com with ESMTPS id l23si10380308pfj.53.2016.03.10.19.03.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 10 Mar 2016 19:03:15 -0800 (PST)
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 11 Mar 2016 08:33:12 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2B339Ug3080684
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 08:33:09 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2B8W5vW000850
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 14:02:06 +0530
Message-ID: <56E2356B.5030600@linux.vnet.ibm.com>
Date: Fri, 11 Mar 2016 08:33:07 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC 3/9] mm/gup: Make follow_page_mask function PGD implementation
 aware
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com> <1457525450-4262-3-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1457525450-4262-3-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, aneesh.kumar@linux.vnet.ibm.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 03/09/2016 05:40 PM, Anshuman Khandual wrote:
> Currently the function 'follow_page_mask' does not take into account
> PGD based huge page implementation. This change achieves that and
> makes it complete.

Hugh/Mel/Naoya/Andrew,

	Thoughts/inputs/suggestions ? Does this change look okay ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
