Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0306B0256
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 00:33:54 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id fl4so58252532pad.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 21:33:54 -0800 (PST)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [125.16.236.1])
        by mx.google.com with ESMTPS id m65si3422008pfi.168.2016.03.09.21.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 21:33:53 -0800 (PST)
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 10 Mar 2016 11:03:50 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2A5XV903736054
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 11:03:31 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2A5XjJ7024426
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 11:03:45 +0530
Message-ID: <56E10738.7020204@linux.vnet.ibm.com>
Date: Thu, 10 Mar 2016 11:03:44 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC 4/9] powerpc/mm: Split huge_pte_alloc function for BOOK3S
 64K
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com> <1457525450-4262-4-git-send-email-khandual@linux.vnet.ibm.com> <878u1r1l4m.fsf@linux.vnet.ibm.com>
In-Reply-To: <878u1r1l4m.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 03/10/2016 01:25 AM, Aneesh Kumar K.V wrote:
> Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:
> 
>> > [ text/plain ]
>> > From: root <root@ltcalpine2-lp8.aus.stglabs.ibm.com>
>> >
>> > Currently the 'huge_pte_alloc' function has two versions, one for the
>> > BOOK3S and the other one for the BOOK3E platforms. This change splits
>> > the BOOK3S version into two parts, one for the 4K page size based
>> > implementation and the other one for the 64K page sized implementation.
>> > This change is one of the prerequisites towards enabling GENERAL_HUGETLB
>> > implementation for BOOK3S 64K based huge pages.
> I really wish we reduce #ifdefs in C code and start splitting hash
> and nonhash code out where ever we can.

Okay but here we are only dealing with 64K and 4K configs inside book3s.
I guess it covers both hash and no hash implementations. Not sure if I
got it correctly.

> 
> What we really want here is a book3s version and in book3s version use
> powerpc specific huge_pte_alloc only if GENERAL_HUGETLB was not defined.

got it.

> Don't limit it to 64k linux page size. We should select between powerpc
> specific implementation and generic code using GENERAL_HUGETLB define.

Got it. will try.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
