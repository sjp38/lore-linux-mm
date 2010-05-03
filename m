Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A05516B023A
	for <linux-mm@kvack.org>; Mon,  3 May 2010 12:43:07 -0400 (EDT)
Date: Mon, 3 May 2010 09:41:20 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: Take all anon_vma locks in anon_vma_lock
In-Reply-To: <20100503121847.7997d280@annuminas.surriel.com>
Message-ID: <alpine.LFD.2.00.1005030940490.5478@i5.linux-foundation.org>
References: <20100503121743.653e5ecc@annuminas.surriel.com> <20100503121847.7997d280@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>



On Mon, 3 May 2010, Rik van Riel wrote:
> 
> Both the page migration code and the transparent hugepage patches expect
> 100% reliable rmap lookups and use page_lock_anon_vma(page) to prevent
> races with mmap, munmap, expand_stack, etc.

Pretty much same comments as for the other one. Why are we pandering to 
the case that is/should be unusual?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
