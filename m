Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 08FC76B01EE
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 21:09:53 -0400 (EDT)
Date: Wed, 28 Apr 2010 03:09:20 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm,migration: Remove straggling migration PTEs
 when page tables are being moved after the VMA has already moved
Message-ID: <20100428010920.GK510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <1272403852-10479-4-git-send-email-mel@csn.ul.ie>
 <20100427223004.GF8860@random.random>
 <20100427225852.GH8860@random.random>
 <20100428093948.c4e6faa1.kamezawa.hiroyu@jp.fujitsu.com>
 <20100428010543.GJ510@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428010543.GJ510@random.random>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 03:05:43AM +0200, Andrea Arcangeli wrote:
> 1) adjusting page->index atomically with the pte updates inside pt
>    lock (while it moves from one pte to another)

actually no need of this at all! of course the dst vma will have
vma->vm_pgoff adjusted instead... never mind. So I don't see a problem
there.

I think this is very special of how exec.c abuses move_page_tables by
passing vma as src and dst, when it obviously cannot be indexed in two
anon-vmas because there's a single vma and a single vma->anon_vma, and
src and dst obviously cannot have two different vm_pgoff again because
there's a single vma and there can't be two different vma->vm_pgoff.

So I'm very hopeful do_mremap is already fully safe...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
