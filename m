Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD846B0254
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 00:13:14 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 129so59555201pfw.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 21:13:14 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id w84si2155599pfi.103.2016.03.09.21.13.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 21:13:13 -0800 (PST)
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 10 Mar 2016 15:13:10 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 395143578056
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 16:13:04 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2A5CuaW46268644
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 16:13:04 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2A5CVju021205
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 16:12:31 +1100
Message-ID: <56E10227.2010608@linux.vnet.ibm.com>
Date: Thu, 10 Mar 2016 10:42:07 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC 6/9] powerpc/hugetlb: Enable ARCH_WANT_GENERAL_HUGETLB for
 BOOK3S 64K
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com> <1457525450-4262-6-git-send-email-khandual@linux.vnet.ibm.com> <8760wv1kzr.fsf@linux.vnet.ibm.com>
In-Reply-To: <8760wv1kzr.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 03/10/2016 01:28 AM, Aneesh Kumar K.V wrote:
> Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:
> 
>> > [ text/plain ]
>> > This enables ARCH_WANT_GENERAL_HUGETLB for BOOK3S 64K in Kconfig.
>> > It also implements a new function 'pte_huge' which is required by
>> > function 'huge_pte_alloc' from generic VM. Existing BOOK3S 64K
>> > specific functions 'huge_pte_alloc' and 'huge_pte_offset' (which
>> > are no longer required) are removed with this change.
>> >
> You want this to be the last patch isn't it ? And you are mixing too

Yeah, it should be the last one.

> many things in this patch. Why not do this
> 
> * book3s specific hash pte routines
> * book3s add conditional based on GENERAL_HUGETLB
> * Enable GENERAL_HUGETLB for 64k page size config

which creates three separate patches ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
