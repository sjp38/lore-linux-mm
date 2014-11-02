Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7B86B008C
	for <linux-mm@kvack.org>; Sun,  2 Nov 2014 08:49:48 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id eu11so10677530pac.9
        for <linux-mm@kvack.org>; Sun, 02 Nov 2014 05:49:47 -0800 (PST)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id rf9si13166094pbc.221.2014.11.02.05.49.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 02 Nov 2014 05:49:46 -0800 (PST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 2 Nov 2014 23:49:41 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id ABE4D2BB0023
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 00:49:38 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sA2DnIPP34013200
	for <linux-mm@kvack.org>; Mon, 3 Nov 2014 00:49:27 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sA2Dn5cl009227
	for <linux-mm@kvack.org>; Mon, 3 Nov 2014 00:49:05 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Question/clarification on pmd accessors
Date: Sun, 02 Nov 2014 19:18:46 +0530
Message-ID: <87fve1hfwh.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-arch@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>


Hi Andrea,

This came up when I was looking at how best we can implement generic GUP
that can also handle sparc usecase. Below are the pmd accessors that
would be nice to get documented. 

pmd_present():
        I guess we should return true for both pointer to pte page and
        huge page pte (THP and explicit hugepages). We will always find
        THP and explicit hugepage present. If so how is it
        different from pmd_none() ? (There is an expection of
        __split_huge_page_map marking the pmd not
        present. Should pmd_present() return false in that case ?)

pmd_none():
        In some arch it is same as !pmd_present(). I am
        not sure that is correct. Can we explain the difference between
        !pmd_present and pmd_none ?

pmd_trans_huge():
        pmd value that represent a hugepage built via THP mechanism.
        Also implies present.

pmd_huge():
        Should cover both the THP and explicit hugepages

pmd_large():
        This is confusing. On ppc64 this one also check for
        _PAGE_PRESENT. I don't recollect how we end up with that.

-aneesh

        

        

        

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
