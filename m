Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5EB2B6B0069
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 12:44:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 136so7599299wmu.3
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 09:44:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d30sor7666710edd.36.2017.10.03.09.44.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 09:44:50 -0700 (PDT)
Date: Tue, 3 Oct 2017 19:44:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: remove unnecessary WARN_ONCE in
 page_vma_mapped_walk().
Message-ID: <20171003164448.gasvu5iu3xaoscgo@node.shutemov.name>
References: <20171003142606.12324-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003142606.12324-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org

On Tue, Oct 03, 2017 at 10:26:06AM -0400, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> A non present pmd entry can appear after pmd_lock is taken in
> page_vma_mapped_walk(), even if THP migration is not enabled.
> The WARN_ONCE is unnecessary.
> 
> Fixes: 616b8371539a ("mm: thp: enable thp migration in generic path")
> Reported-and-tested-by: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
