Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 0ED726B00A2
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 11:10:45 -0400 (EDT)
Date: Wed, 17 Apr 2013 17:10:42 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: fix huge zero page logic for page with pfn == 0
Message-ID: <20130417151041.GA25659@redhat.com>
References: <1366211253-14325-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1366211253-14325-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

On Wed, Apr 17, 2013 at 06:07:33PM +0300, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> Current implementation of huge zero page uses pfn value 0 to indicate
> that the page hasn't allocated yet. It assumes that buddy page allocator
> can't return page with pfn == 0.
> 
> Let's rework the code to store 'struct page *' of huge zero page, not
> its pfn. This way we can avoid the weak assumption.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/huge_memory.c |   43 +++++++++++++++++++++----------------------
>  1 file changed, 21 insertions(+), 22 deletions(-)

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
