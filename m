Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E2B006B01F3
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 20:20:01 -0400 (EDT)
Date: Wed, 28 Apr 2010 02:19:11 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] mm,migration: During fork(), wait for migration to
 end if migration PTE is encountered
Message-ID: <20100428001911.GG510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <1272403852-10479-2-git-send-email-mel@csn.ul.ie>
 <20100427222245.GE8860@random.random>
 <20100428085203.4336b761.kamezawa.hiroyu@jp.fujitsu.com>
 <20100428001821.GF510@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428001821.GF510@random.random>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 02:18:21AM +0200, Andrea Arcangeli wrote:
> On Wed, Apr 28, 2010 at 08:52:03AM +0900, KAMEZAWA Hiroyuki wrote:
> > I already explained this doesn't happend and said "I'm sorry".
> 
> Oops I must have overlooked it sorry! I just seen the trace quoted in
> the comment of the patch and that at least would need correction
> before it can be pushed in mainline, or it creates huge confusion to
> see a reverse trace for CPU A for an already tricky piece of code.
> 
> > But considering maintainance, it's not necessary to copy migration ptes
> > and we don't have to keep a fundamental risks of migration circus.
> > 
> > So, I don't say "we don't need this patch."
> 
> split_huge_page also has the same requirement and there is no bug to
> fix, so I don't see why to make special changes for just migrate.c
> when we still have to list_add_tail for split_huge_page.
> 
> Furthermore this patch isn't fixing anything in any case and it looks
> a noop to me. If the order ever gets inverted, and process2 ptes are
> scanned before process1 ptes in the rmap_walk, sure the
> copy-page-tables will break and stop until the process1 rmap_walk will
> complete, but that is not enough! You have to repeat the rmap_walk of
> process1 if the order ever gets inverted and this isn't happening in
  ^^^^^^^2
> the patch so I don't see how it could make any difference even just
> for migrate.c (obviously not for split_huge_page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
