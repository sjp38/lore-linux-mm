Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E53EB600794
	for <linux-mm@kvack.org>; Mon,  3 May 2010 12:39:05 -0400 (EDT)
Date: Mon, 3 May 2010 09:37:17 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: fix race between shift_arg_pages and rmap_walk
In-Reply-To: <alpine.LFD.2.00.1005030928350.5478@i5.linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1005030935100.5478@i5.linux-foundation.org>
References: <20100503121743.653e5ecc@annuminas.surriel.com> <20100503121929.260ed5ee@annuminas.surriel.com> <alpine.LFD.2.00.1005030928350.5478@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>



On Mon, 3 May 2010, Linus Torvalds wrote:
> 
> It looks like it makes execve() do a totally insane "create and then 
> immediately destroy temporary vma and anon_vma chain" for a case that is 
> unlikely to ever matter. 
> 
> In fact, for a case that isn't even normally _enabled_, namely migration.
> 
> Why would we want to slow down execve() for that?

Alternate suggestions:

 - clean up the patch so that it is explicitly abouy migration, and 
   doesn't even get enabled for anything else.

 - make the migration code take the VM lock for writing (why doesn't it 
   already?) and never race with things like this in the first place.

 - explain why the new code isn't any slower.

Hmm?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
