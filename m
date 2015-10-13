Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7ABCF6B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 02:24:12 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so11544824pab.2
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 23:24:12 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id bc7si2671095pbd.145.2015.10.12.23.24.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 23:24:11 -0700 (PDT)
Received: by pabve7 with SMTP id ve7so11544492pab.2
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 23:24:11 -0700 (PDT)
Date: Tue, 13 Oct 2015 15:26:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] thp: use is_zero_pfn only after pte_present check
Message-ID: <20151013062630.GA16146@bbox>
References: <1444703918-16597-1-git-send-email-minchan@kernel.org>
 <20151013054124.GB20952@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151013054124.GB20952@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Oct 12, 2015 at 10:41:24PM -0700, Greg Kroah-Hartman wrote:
> On Tue, Oct 13, 2015 at 11:38:38AM +0900, Minchan Kim wrote:
> > Use is_zero_pfn on pteval only after pte_present check on pteval
> > (It might be better idea to introduce is_zero_pte where checks
> > pte_present first). Otherwise, it could work with swap or
> > migration entry and if pte_pfn's result is equal to zero_pfn
> > by chance, we lose user's data in __collapse_huge_page_copy.
> > So if you're luck, the application is segfaulted and finally you
> > could see below message when the application is exit.
> > 
> > BUG: Bad rss-counter state mm:ffff88007f099300 idx:2 val:3
> > 
> > Cc: <stable@vger.kernel.org>
> > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> > Hello Greg,
> > 
> > This patch should go to -stable but when you will apply it
> > after merging of linus tree, it will be surely conflicted due
> > to userfaultfd part.
> > 
> > I want to know how to handle it.
> 
> You will get an automated email saying it didn't apply and then you
> provide a backported version.  Or you send a properly backported version
> to stable@vger.kernel.org before then, with the git commit id of the
> patch in Linus's tree.

Okay, I will send a right version when I received automatd email.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
