Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 179826007B8
	for <linux-mm@kvack.org>; Mon,  3 May 2010 13:11:27 -0400 (EDT)
Received: from f199130.upc-f.chello.nl ([80.56.199.130] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1O8zAw-0004Rt-BZ
	for linux-mm@kvack.org; Mon, 03 May 2010 17:11:22 +0000
Subject: Re: [PATCH 1/2] mm: Take all anon_vma locks in anon_vma_lock
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100503170230.GF19891@random.random>
References: <20100503121743.653e5ecc@annuminas.surriel.com>
	 <20100503121847.7997d280@annuminas.surriel.com>
	 <1272905712.1642.150.camel@laptop>  <20100503170230.GF19891@random.random>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 03 May 2010 19:11:19 +0200
Message-ID: <1272906679.1642.152.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-05-03 at 19:02 +0200, Andrea Arcangeli wrote:
> On Mon, May 03, 2010 at 06:55:12PM +0200, Peter Zijlstra wrote:
> > This does leave me worrying about concurrent faults poking at
> > vma->vm_end without synchronization.
> 
> I didn't check this patch in detail yet. I agree it can be removed and
> I think it can be safely replaced with the page_table_lock.

Sure, it could probably be replaced with the ptl, but a single
anon_vma->lock would I think be better since there's more of them.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
