Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3553A82FC4
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 20:13:00 -0500 (EST)
Received: by mail-yk0-f182.google.com with SMTP id x67so47201710ykd.2
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 17:13:00 -0800 (PST)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com. [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id u130si24824881ywe.79.2015.12.24.17.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Dec 2015 17:12:59 -0800 (PST)
Received: by mail-yk0-x22a.google.com with SMTP id x184so234784436yka.3
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 17:12:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <567C978E.3090007@oracle.com>
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1450957883-96356-3-git-send-email-kirill.shutemov@linux.intel.com>
	<567C978E.3090007@oracle.com>
Date: Thu, 24 Dec 2015 17:12:59 -0800
Message-ID: <CAPcyv4gc-iGNvLHRQxP4NAGc1u41jbCVnZ=iwgpLSNN3Dw7=uw@mail.gmail.com>
Subject: Re: [PATCH 2/4] thp: fix regression in handling mlocked pages in __split_huge_pmd()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On Thu, Dec 24, 2015 at 5:10 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
> On 12/24/2015 06:51 AM, Kirill A. Shutemov wrote:
>> This patch fixes regression caused by patch
>>  "mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd"
>>
>> The patch makes pmd_trans_huge() check and "page = pmd_page(*pmd)" after
>> __split_huge_pmd_locked(). It can never succeed, since the pmd already
>> points to a page table. As result the page is never get munlocked.
>>
>> It causes crashes like this:
>>  http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com
>
> So this patch didn't fix the issue for me. I've sent Kirill the trace
> off-list, but it's essentially the same thing.

Can you send me the trace as well, and the reproducer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
