Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3AE326007B8
	for <linux-mm@kvack.org>; Mon,  3 May 2010 13:05:05 -0400 (EDT)
Date: Mon, 3 May 2010 19:02:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: Take all anon_vma locks in anon_vma_lock
Message-ID: <20100503170230.GF19891@random.random>
References: <20100503121743.653e5ecc@annuminas.surriel.com>
 <20100503121847.7997d280@annuminas.surriel.com>
 <1272905712.1642.150.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1272905712.1642.150.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 03, 2010 at 06:55:12PM +0200, Peter Zijlstra wrote:
> This does leave me worrying about concurrent faults poking at
> vma->vm_end without synchronization.

I didn't check this patch in detail yet. I agree it can be removed and
I think it can be safely replaced with the page_table_lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
