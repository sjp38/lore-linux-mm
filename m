Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 984E66B005D
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 08:55:13 -0400 (EDT)
Date: Tue, 23 Jun 2009 20:56:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] hugetlb: fault flags instead of write_access
Message-ID: <20090623125644.GA18603@localhost>
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain> <Pine.LNX.4.64.0906231345001.19552@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906231345001.19552@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 23, 2009 at 08:49:05PM +0800, Hugh Dickins wrote:
> handle_mm_fault() is now passing fault flags rather than write_access
> down to hugetlb_fault(), so better recognize that in hugetlb_fault(),
> and in hugetlb_no_page().
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Looks OK and compiles OK.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
