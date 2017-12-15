Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1568B6B0069
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 05:01:54 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id s5so1049606wra.3
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 02:01:54 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w46sor3867218eda.57.2017.12.15.02.01.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 02:01:53 -0800 (PST)
Date: Fri, 15 Dec 2017 13:01:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Reduce memory bloat with THP
Message-ID: <20171215100151.b7j66q7sg2wsrex3@node.shutemov.name>
References: <1513301359-117568-1-git-send-email-nitin.m.gupta@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513301359-117568-1-git-send-email-nitin.m.gupta@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <nitin.m.gupta@oracle.com>
Cc: linux-mm@kvack.org, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, SeongJae Park <sj38.park@gmail.com>, Shaohua Li <shli@fb.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, open list <linux-kernel@vger.kernel.org>

On Thu, Dec 14, 2017 at 05:28:52PM -0800, Nitin Gupta wrote:
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 751e97a..b2ec07b 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -508,6 +508,7 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
>  					unsigned long start, unsigned long end)
>  {
>  	zap_page_range(vma, start, end - start);
> +	vma->space_efficient = true;
>  	return 0;
>  }
>  

And this modifies vma without down_write(mmap_sem).

No.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
