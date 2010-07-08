Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 897966B0071
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 02:39:10 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o686d7BR018666
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 8 Jul 2010 15:39:07 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EC7D245DE4D
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 15:39:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BE42E45DE6F
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 15:39:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A86151DB803B
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 15:39:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BA3A1DB804A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 15:39:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
In-Reply-To: <20100706202758.GC18210@cmpxchg.org>
References: <20100706152539.GG13780@csn.ul.ie> <20100706202758.GC18210@cmpxchg.org>
Message-Id: <20100708153811.CD30.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  8 Jul 2010 15:39:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Jul 06, 2010 at 04:25:39PM +0100, Mel Gorman wrote:
> > On Tue, Jul 06, 2010 at 08:24:57PM +0900, Minchan Kim wrote:
> > > but it is still problem in case of swap file.
> > > That's because swapout on swapfile cause file system writepage which
> > > makes kernel stack overflow.
> > 
> > I don't *think* this is a problem unless I missed where writing out to
> > swap enters teh filesystem code. I'll double check.
> 
> It bypasses the fs.  On swapon, the blocks are resolved
> (mm/swapfile.c::setup_swap_extents) and then the writeout path uses
> bios directly (mm/page_io.c::swap_writepage).

Yeah, my fault. I did misunderstand this.

Thank you.



> 
> (GFP_NOFS still includes __GFP_IO, so allows swapping)
> 
> 	Hannes



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
