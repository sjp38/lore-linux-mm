Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E5FD26B0009
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 19:04:56 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m18so3535253pgu.14
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 16:04:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g3-v6si5002806pll.290.2018.03.15.16.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 16:04:55 -0700 (PDT)
Date: Thu, 15 Mar 2018 16:04:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/khugepaged: Convert VM_BUG_ON() to collapse fail
Message-Id: <20180315160453.dff17cfe3dca056dabc98b9e@linux-foundation.org>
In-Reply-To: <20180315152353.27989-1-kirill.shutemov@linux.intel.com>
References: <20180315152353.27989-1-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 15 Mar 2018 18:23:53 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> khugepaged is not yet able to convert PTE-mapped huge pages back to PMD
> mapped. We do not collapse such pages. See check khugepaged_scan_pmd().
> 
> But if between khugepaged_scan_pmd() and __collapse_huge_page_isolate()
> somebody managed to instantiate THP in the range and then split the PMD
> back to PTEs we would have a problem -- VM_BUG_ON_PAGE(PageCompound(page))
> will get triggered.
> 
> It's possible since we drop mmap_sem during collapse to re-take for
> write.
> 
> Replace the VM_BUG_ON() with graceful collapse fail.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: b1caa957ae6d ("khugepaged: ignore pmd tables with THP mapped with ptes")

Jan 2016.  Do we need a cc:stable?
