Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 26F726B00AE
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 10:42:06 -0400 (EDT)
Message-ID: <4C8A43A9.2030907@redhat.com>
Date: Fri, 10 Sep 2010 10:41:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] hugetlb, rmap: fix confusing page locking in hugetlb_cow()
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1284092586-1179-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1284092586-1179-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 09/10/2010 12:23 AM, Naoya Horiguchi wrote:
> if(!trylock_page) block in avoidcopy path of hugetlb_cow() looks confusing
> and is buggy.  Originally this trylock_page() is intended to make sure
> that old_page is locked even when old_page != pagecache_page, because then
> only pagecache_page is locked.
> This patch fixes it by moving page locking into hugetlb_fault().
>
> Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
