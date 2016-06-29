Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7616B0253
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 03:26:43 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id at7so85333931obd.1
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 00:26:43 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id l12si3389292iod.67.2016.06.29.00.26.41
        for <linux-mm@kvack.org>;
        Wed, 29 Jun 2016 00:26:42 -0700 (PDT)
Date: Wed, 29 Jun 2016 16:27:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm, THP: Clean up return value of
 madvise_free_huge_pmd
Message-ID: <20160629072708.GC18523@bbox>
References: <1467135452-16688-1-git-send-email-ying.huang@intel.com>
 <1467135452-16688-2-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
In-Reply-To: <1467135452-16688-2-git-send-email-ying.huang@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jerome Marchand <jmarchan@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 28, 2016 at 10:36:30AM -0700, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> The definition of return value of madvise_free_huge_pmd is not clear
> before.  According to the suggestion of Minchan Kim, change the type of
> return value to bool and return true if we do MADV_FREE successfully on
> entire pmd page, otherwise, return false.  Comments are added too.
> 
> Cc: Minchan Kim <minchan@kernel.org>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
