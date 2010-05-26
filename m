Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ED69F6B01AD
	for <linux-mm@kvack.org>; Wed, 26 May 2010 00:16:35 -0400 (EDT)
Date: Tue, 25 May 2010 21:15:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v2 4/5] always lock the root (oldest) anon_vma
Message-Id: <20100525211520.16e3a034.akpm@linux-foundation.org>
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
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, james toy <toyj@union.edu>, james toy <mail@wfys.org>, James Toy <0xbaadface@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 26 May 2010 00:00:15 -0400 Rik van Riel <riel@redhat.com> wrote:

> On 05/13/2010 05:09 PM, Andrew Morton wrote:
> 
> > I'm not very confident in merging all these onto the current MM pile.
> 
> Blah.  I thought I just did that (and wondered why it was
> so easy), and then I saw that the MMOTM git tree is old
> and does not have the COMPACTION code :(
> 

Oh.  James's mmotm->git bot might have broken.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
