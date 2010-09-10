Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 54F686B0099
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 05:04:43 -0400 (EDT)
Date: Fri, 10 Sep 2010 11:04:38 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/4] hugetlb, rmap: fixes and cleanups
Message-ID: <20100910110438.6aaf181e@basil.nowhere.org>
In-Reply-To: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Sep 2010 13:23:02 +0900
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Hi,
> 
> These are fix and cleanup patches for hugepage rmapping.
> All these were pointed out in the following thread (last 4 messages.)
> 
>   http://thread.gmane.org/gmane.linux.kernel.mm/52334

Looks all good to me. It's not strictly hwpoison related
though, so I assume they are better with Andrew than my tree.

I assume they do not depend on the earlier patchkit?
 
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
