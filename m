Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B0ACC6B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 01:53:12 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so10569045pad.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 22:53:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id yw10si2494582pac.86.2015.10.12.22.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 22:53:11 -0700 (PDT)
Date: Mon, 12 Oct 2015 22:41:24 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2] thp: use is_zero_pfn only after pte_present check
Message-ID: <20151013054124.GB20952@kroah.com>
References: <1444703918-16597-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444703918-16597-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Oct 13, 2015 at 11:38:38AM +0900, Minchan Kim wrote:
> Use is_zero_pfn on pteval only after pte_present check on pteval
> (It might be better idea to introduce is_zero_pte where checks
> pte_present first). Otherwise, it could work with swap or
> migration entry and if pte_pfn's result is equal to zero_pfn
> by chance, we lose user's data in __collapse_huge_page_copy.
> So if you're luck, the application is segfaulted and finally you
> could see below message when the application is exit.
> 
> BUG: Bad rss-counter state mm:ffff88007f099300 idx:2 val:3
> 
> Cc: <stable@vger.kernel.org>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> Hello Greg,
> 
> This patch should go to -stable but when you will apply it
> after merging of linus tree, it will be surely conflicted due
> to userfaultfd part.
> 
> I want to know how to handle it.

You will get an automated email saying it didn't apply and then you
provide a backported version.  Or you send a properly backported version
to stable@vger.kernel.org before then, with the git commit id of the
patch in Linus's tree.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
