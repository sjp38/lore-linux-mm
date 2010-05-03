Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9FFA4600794
	for <linux-mm@kvack.org>; Mon,  3 May 2010 12:36:09 -0400 (EDT)
Date: Mon, 3 May 2010 09:34:14 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: fix race between shift_arg_pages and rmap_walk
In-Reply-To: <20100503121929.260ed5ee@annuminas.surriel.com>
Message-ID: <alpine.LFD.2.00.1005030928350.5478@i5.linux-foundation.org>
References: <20100503121743.653e5ecc@annuminas.surriel.com> <20100503121929.260ed5ee@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>



On Mon, 3 May 2010, Rik van Riel wrote:
> 
> migrate.c requires rmap to be able to find all ptes mapping a page at
> all times, otherwise the migration entry can be instantiated, but it
> can't be removed if the second rmap_walk fails to find the page.

Please correct me if I'm wrong, but this patch looks like pure and utter 
garbage.

It looks like it makes execve() do a totally insane "create and then 
immediately destroy temporary vma and anon_vma chain" for a case that is 
unlikely to ever matter. 

In fact, for a case that isn't even normally _enabled_, namely migration.

Why would we want to slow down execve() for that?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
