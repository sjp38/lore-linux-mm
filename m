Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0152782FC4
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 20:12:28 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id x184so234778259yka.3
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 17:12:27 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c3si32501272ywe.137.2015.12.24.17.12.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Dec 2015 17:12:27 -0800 (PST)
Subject: Re: [-mm PATCH v5 15/18] mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd
References: <20151221054526.34542.25205.stgit@dwillia2-desk3.jf.intel.com>
 <20151225005623.19962.1972.stgit@dwillia2-desk3.jf.intel.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <567C97D8.5040002@oracle.com>
Date: Thu, 24 Dec 2015 20:11:52 -0500
MIME-Version: 1.0
In-Reply-To: <20151225005623.19962.1972.stgit@dwillia2-desk3.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, linux-nvdimm@ml01.01.org, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 12/24/2015 07:59 PM, Dan Williams wrote:
> A dax-huge-page mapping while it uses some thp helpers is ultimately not a
> transparent huge page.  The distinction is especially important in the
> get_user_pages() path.  pmd_devmap() is used to distinguish dax-pmds from
> pmd_huge() and pmd_trans_huge() which have slightly different semantics.
> 
> Explicitly mark the pmd_trans_huge() helpers that dax needs by adding
> pmd_devmap() checks.
> 
> Cc: Dave Hansen <dave@sr71.net>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reported-by: Matthew Wilcox <willy@linux.intel.com>
> Reported-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

The issue that I've reported and Kirill sent for isn't fixed for me,
so either the bug isn't really within this patch, or it wasn't addressed
correctly.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
