Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 79DF06B01AD
	for <linux-mm@kvack.org>; Wed, 26 May 2010 00:01:25 -0400 (EDT)
Message-ID: <4BFC9CCF.6000809@redhat.com>
Date: Wed, 26 May 2010 00:00:15 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v2 4/5] always lock the root (oldest) anon_vma
References: <20100512133815.0d048a86@annuminas.surriel.com>	<20100512134029.36c286c4@annuminas.surriel.com>	<20100512210216.GP24989@csn.ul.ie>	<4BEB18BB.5010803@redhat.com>	<20100513095439.GA27949@csn.ul.ie>	<20100513103356.25665186@annuminas.surriel.com> <20100513140919.0a037845.akpm@linux-foundation.org>
In-Reply-To: <20100513140919.0a037845.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On 05/13/2010 05:09 PM, Andrew Morton wrote:

> I'm not very confident in merging all these onto the current MM pile.

Blah.  I thought I just did that (and wondered why it was
so easy), and then I saw that the MMOTM git tree is old
and does not have the COMPACTION code :(

On to doing this thing again :/

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
