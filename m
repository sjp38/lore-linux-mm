Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 22C226B01EF
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:22:18 -0400 (EDT)
Date: Wed, 28 Apr 2010 02:20:56 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] Fix migration races in rmap_walk() V2
Message-ID: <20100428002056.GH510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <alpine.DEB.2.00.1004271723090.24133@router.home>
 <20100427223242.GG8860@random.random>
 <20100428091345.496ca4c4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428091345.496ca4c4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 09:13:45AM +0900, KAMEZAWA Hiroyuki wrote:
> Doing some check in move_ptes() after vma_adjust() is not safe.
> IOW, when vma's information and information in page-table is incosistent...objrmap
> is broken and migartion will cause panic.
> 
> Then...I think there are 2 ways.
>   1. use seqcounter in "mm_struct" as previous patch and lock it at mremap.
> or
>   2. get_user_pages_fast() when do remap.

3 take the anon_vma->lock

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
