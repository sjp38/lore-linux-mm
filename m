Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C3ADF60021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 17:35:54 -0500 (EST)
Date: Tue, 8 Dec 2009 14:35:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm hugetlb x86: fix hugepage memory leak in mincore()
Message-Id: <20091208143506.250b47c7.akpm@linux-foundation.org>
In-Reply-To: <4B1CB5D2.7020403@ah.jp.nec.com>
References: <1260172193-14397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<4B1CB5D2.7020403@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: n-horiguchi@ah.jp.nec.com
Cc: LKML <linux-kernel@vger.kernel.org>, hugh.dickins@tiscali.co.uk, linux-mm <linux-mm@kvack.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 07 Dec 2009 16:59:14 +0900
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Most callers of pmd_none_or_clear_bad() check whether the target
> page is in a hugepage or not, but mincore() and walk_page_range()
> do not check it. So if we use mincore() on a hugepage on x86 machine,
> the hugepage memory is leaked as shown below.
> This patch fixes it by extending mincore() system call to support hugepages.

This bug is fairly embarrassing.  I tagged the patch for a -stable
backport.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
