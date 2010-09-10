Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 460CA6B00B2
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 10:50:34 -0400 (EDT)
Date: Fri, 10 Sep 2010 16:37:25 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/4] hugetlb, rmap: always use anon_vma root pointer
Message-ID: <20100910143724.GV8925@random.random>
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1284092586-1179-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1284092586-1179-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 10, 2010 at 01:23:03PM +0900, Naoya Horiguchi wrote:
> This patch applies Andrea's fix given by the following patch into hugepage
> rmapping code:
> 
>   commit 288468c334e98aacbb7e2fb8bde6bc1adcd55e05
>   Author: Andrea Arcangeli <aarcange@redhat.com>
>   Date:   Mon Aug 9 17:19:09 2010 -0700
> 
> This patch uses anon_vma->root and avoids unnecessary overwriting when
> anon_vma is already set up.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/rmap.c |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)

Acked-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
