Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E4AAF6B025F
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 03:25:58 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id o10so1717241obp.3
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 00:25:58 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id z201si3422867itb.5.2016.06.29.00.25.57
        for <linux-mm@kvack.org>;
        Wed, 29 Jun 2016 00:25:58 -0700 (PDT)
Date: Wed, 29 Jun 2016 16:26:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] MADVISE_FREE, THP: Fix madvise_free_huge_pmd return
 value after splitting
Message-ID: <20160629072624.GB18523@bbox>
References: <1467135452-16688-1-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
In-Reply-To: <1467135452-16688-1-git-send-email-ying.huang@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 28, 2016 at 10:36:29AM -0700, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> madvise_free_huge_pmd should return 0 if the fallback PTE operations are
> required.  In madvise_free_huge_pmd, if part pages of THP are discarded,
> the THP will be split and fallback PTE operations should be used if
> splitting succeeds.  But the original code will make fallback PTE
> operations skipped, after splitting succeeds.  Fix that via make
> madvise_free_huge_pmd return 0 after splitting successfully, so that the
> fallback PTE operations will be done.
> 
> Cc: Minchan Kim <minchan@kernel.org>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
