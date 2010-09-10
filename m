Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6ABCC6B00A8
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 10:40:02 -0400 (EDT)
Message-ID: <4C8A4353.5050802@redhat.com>
Date: Fri, 10 Sep 2010 10:40:19 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] hugetlb, rmap: always use anon_vma root pointer
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1284092586-1179-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1284092586-1179-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 09/10/2010 12:23 AM, Naoya Horiguchi wrote:
> This patch applies Andrea's fix given by the following patch into hugepage
> rmapping code:
>
>    commit 288468c334e98aacbb7e2fb8bde6bc1adcd55e05
>    Author: Andrea Arcangeli<aarcange@redhat.com>
>    Date:   Mon Aug 9 17:19:09 2010 -0700
>
> This patch uses anon_vma->root and avoids unnecessary overwriting when
> anon_vma is already set up.
>
> Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
