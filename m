Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6C38F6B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 15:41:31 -0400 (EDT)
Date: Thu, 22 Apr 2010 14:40:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of PageSwapCache
 pages
In-Reply-To: <20100422192923.GH30306@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1004221439040.5023@router.home>
References: <20100421153421.GM30306@csn.ul.ie> <alpine.DEB.2.00.1004211038020.4959@router.home> <20100422092819.GR30306@csn.ul.ie> <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com> <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com>
 <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com> <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com> <20100422141404.GA30306@csn.ul.ie> <p2y28c262361004220718m3a5e3e2ekee1fef7ebdae8e73@mail.gmail.com> <20100422154003.GC30306@csn.ul.ie>
 <20100422192923.GH30306@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010, Mel Gorman wrote:

> vma_adjust() is updating anon VMA information without any locks taken.
> In constract, file-backed mappings use the i_mmap_lock. This lack of
> locking can result in races with page migration. During rmap_walk(),
> vma_address() can return -EFAULT for an address that will soon be valid.
> This leaves a dangling migration PTE behind which can later cause a
> BUG_ON to trigger when the page is faulted in.

Isnt this also a race with reclaim /  swap?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
