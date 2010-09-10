Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 49F816B00AD
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 10:41:43 -0400 (EDT)
Message-ID: <4C8A43BD.6020301@redhat.com>
Date: Fri, 10 Sep 2010 10:42:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] hugetlb, rmap: add BUG_ON(!PageLocked) in hugetlb_add_anon_rmap()
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1284092586-1179-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1284092586-1179-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 09/10/2010 12:23 AM, Naoya Horiguchi wrote:
> Confirming page lock is held in hugetlb_add_anon_rmap() may be useful
> to detect possible future problems.
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
