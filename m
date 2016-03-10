Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 336DC6B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 00:06:02 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id tt10so57950770pab.3
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 21:06:02 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [125.16.236.2])
        by mx.google.com with ESMTPS id l73si3270027pfi.113.2016.03.09.21.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 21:06:00 -0800 (PST)
Received: from localhost
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 10 Mar 2016 10:35:57 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2A55shM6684996
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 10:35:54 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2AAYpPi029989
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 16:04:52 +0530
Message-ID: <56E100AF.9060501@linux.vnet.ibm.com>
Date: Thu, 10 Mar 2016 10:35:51 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC 9/9] selfttest/powerpc: Add memory page migration tests
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com> <1457525450-4262-9-git-send-email-khandual@linux.vnet.ibm.com> <8737rz1kvq.fsf@linux.vnet.ibm.com>
In-Reply-To: <8737rz1kvq.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 03/10/2016 01:31 AM, Aneesh Kumar K.V wrote:
> Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:
> 
>> > [ text/plain ]
>> > This adds two tests for memory page migration. One for normal page
>> > migration which works for both 4K or 64K base page size kernel and
>> > the other one is for huge page migration which works only on 64K
>> > base page sized 16MB huge page implemention at the PMD level.
>> >
> can you also add the test in this commit
> e66f17ff717 ("mm/hugetlb: take page table lock in follow_huge_pmd()")

Thought about it but thats kind of bit tricky. All self tests have finite
runtime. Test case in that commit has two processes which execute for ever
and try to create the race condition. We can try to run it for *some time*
looking for races instead ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
