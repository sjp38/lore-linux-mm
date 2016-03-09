Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 244526B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 15:01:47 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id fz5so58646317obc.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 12:01:47 -0800 (PST)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id nx7si107971obc.71.2016.03.09.12.01.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 12:01:46 -0800 (PST)
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 9 Mar 2016 13:01:25 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 954FA1FF001F
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 12:49:32 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u29K1NPr41287846
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 13:01:23 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u29K1MgM032367
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 13:01:23 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC 9/9] selfttest/powerpc: Add memory page migration tests
In-Reply-To: <1457525450-4262-9-git-send-email-khandual@linux.vnet.ibm.com>
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com> <1457525450-4262-9-git-send-email-khandual@linux.vnet.ibm.com>
Date: Thu, 10 Mar 2016 01:31:13 +0530
Message-ID: <8737rz1kvq.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mpe@ellerman.id.au

Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:

> [ text/plain ]
> This adds two tests for memory page migration. One for normal page
> migration which works for both 4K or 64K base page size kernel and
> the other one is for huge page migration which works only on 64K
> base page sized 16MB huge page implemention at the PMD level.
>

can you also add the test in this commit
e66f17ff717 ("mm/hugetlb: take page table lock in follow_huge_pmd()")

> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
