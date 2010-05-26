Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 528CA6B01EA
	for <linux-mm@kvack.org>; Wed, 26 May 2010 11:29:08 -0400 (EDT)
Date: Wed, 26 May 2010 11:24:03 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -v2 0/5] always lock the root anon_vma
Message-ID: <20100526112403.635be0ed@annuminas.surriel.com>
In-Reply-To: <4BFC9CCF.6000809@redhat.com>
References: <20100512133815.0d048a86@annuminas.surriel.com>
	<20100512134029.36c286c4@annuminas.surriel.com>
	<20100512210216.GP24989@csn.ul.ie>
	<4BEB18BB.5010803@redhat.com>
	<20100513095439.GA27949@csn.ul.ie>
	<20100513103356.25665186@annuminas.surriel.com>
	<20100513140919.0a037845.akpm@linux-foundation.org>
	<4BFC9CCF.6000809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 26 May 2010 00:00:15 -0400
Rik van Riel <riel@redhat.com> wrote:
> On 05/13/2010 05:09 PM, Andrew Morton wrote:
> 
> > I'm not very confident in merging all these onto the current MM pile.
> 
> Blah.  I thought I just did that (and wondered why it was
> so easy), and then I saw that the MMOTM git tree is old
> and does not have the COMPACTION code :(
> 
> On to doing this thing again :/

Andrew, here are the patches to always lock the root anon_vma,
ported to the latest -mm tree.

These patches implement Linus's idea of always locking the root
anon_vma and contain all the fixes and improvements suggested 
by Andrea.

This should fix the last bits of the anon_vma locking.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
