Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 23B6082FC4
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 20:10:46 -0500 (EST)
Received: by mail-yk0-f176.google.com with SMTP id x184so234757141yka.3
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 17:10:46 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l13si31309375ywb.45.2015.12.24.17.10.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Dec 2015 17:10:45 -0800 (PST)
Subject: Re: [PATCH 2/4] thp: fix regression in handling mlocked pages in
 __split_huge_pmd()
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1450957883-96356-3-git-send-email-kirill.shutemov@linux.intel.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <567C978E.3090007@oracle.com>
Date: Thu, 24 Dec 2015 20:10:38 -0500
MIME-Version: 1.0
In-Reply-To: <1450957883-96356-3-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>

On 12/24/2015 06:51 AM, Kirill A. Shutemov wrote:
> This patch fixes regression caused by patch
>  "mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd"
> 
> The patch makes pmd_trans_huge() check and "page = pmd_page(*pmd)" after
> __split_huge_pmd_locked(). It can never succeed, since the pmd already
> points to a page table. As result the page is never get munlocked.
> 
> It causes crashes like this:
>  http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com

So this patch didn't fix the issue for me. I've sent Kirill the trace
off-list, but it's essentially the same thing.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
