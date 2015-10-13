Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A34D46B0255
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 05:08:12 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so15717602pac.3
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 02:08:12 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id tl10si3632853pbc.253.2015.10.13.02.08.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 02:08:11 -0700 (PDT)
Received: by pabve7 with SMTP id ve7so15968267pab.2
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 02:08:11 -0700 (PDT)
Date: Tue, 13 Oct 2015 18:10:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] thp: use is_zero_pfn only after pte_present check
Message-ID: <20151013091053.GA6630@bbox>
References: <1444703918-16597-1-git-send-email-minchan@kernel.org>
 <561CB297.9080600@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <561CB297.9080600@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Oct 13, 2015 at 09:28:23AM +0200, Vlastimil Babka wrote:
> On 10/13/2015 04:38 AM, Minchan Kim wrote:
> >Use is_zero_pfn on pteval only after pte_present check on pteval
> >(It might be better idea to introduce is_zero_pte where checks
> >pte_present first). Otherwise, it could work with swap or
> >migration entry and if pte_pfn's result is equal to zero_pfn
> >by chance, we lose user's data in __collapse_huge_page_copy.
> >So if you're luck, the application is segfaulted and finally you
> >could see below message when the application is exit.
> >
> >BUG: Bad rss-counter state mm:ffff88007f099300 idx:2 val:3
> >
> >Cc: <stable@vger.kernel.org>
> 
> More specific:
> Cc: <stable@vger.kernel.org> # 4.1+
> Fixes: ca0984caa823 ("mm: incorporate zero pages into transparent
> huge pages")
> 
> >Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks for the detail and review, Vlastimil.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
