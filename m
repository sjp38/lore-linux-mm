Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4317F6B00B1
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 10:43:48 -0400 (EDT)
Date: Fri, 10 Sep 2010 16:44:13 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/4] hugetlb, rmap: add BUG_ON(!PageLocked) in
 hugetlb_add_anon_rmap()
Message-ID: <20100910144413.GX8925@random.random>
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1284092586-1179-5-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1284092586-1179-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 10, 2010 at 01:23:06PM +0900, Naoya Horiguchi wrote:
> Confirming page lock is held in hugetlb_add_anon_rmap() may be useful
> to detect possible future problems.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/rmap.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)

Acked-by: Andrea Arcangeli <aarcange@redhat.com>

It should probably be a VM_BUG_ON like do_page_add_anon_rmap, but
given the tiny hugetlbfs userbase it's ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
