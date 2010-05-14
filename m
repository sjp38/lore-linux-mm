Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC4596B0212
	for <linux-mm@kvack.org>; Fri, 14 May 2010 05:33:24 -0400 (EDT)
Date: Fri, 14 May 2010 10:33:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH -v2 4/5] always lock the root (oldest) anon_vma
Message-ID: <20100514093303.GA21481@csn.ul.ie>
References: <20100512133815.0d048a86@annuminas.surriel.com> <20100512134029.36c286c4@annuminas.surriel.com> <20100512210216.GP24989@csn.ul.ie> <4BEB18BB.5010803@redhat.com> <20100513095439.GA27949@csn.ul.ie> <20100513103356.25665186@annuminas.surriel.com> <20100513140919.0a037845.akpm@linux-foundation.org> <4BEC8235.4060509@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4BEC8235.4060509@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 06:50:29PM -0400, Rik van Riel wrote:
> On 05/13/2010 05:09 PM, Andrew Morton wrote:
>
>> I'm not very confident in merging all these onto the current MM pile.
>
> My apologies, I built them onto Linus's latest git
> tree (where I know I did get all the anon_vma->lock
> instances).
>

And the instance Andrew ran into was specific to a migration fix in
mmotm where it was possible for anon_vma to disappear during migration.

> Andrew, Mel, want me to make a version of this series
> against -mmotm, or does the migrate & compaction code
> need to be modified in some non-obvious way that would
> require Mel to create a new compaction series on top
> of these anon_vma patches?
>

I'd like to see a version on top of mmotm at least. It isn't clear to me what
order these anon_vma changes were going in. Compaction should not be
affected by this series but the fixes to migration are. I'd expect the
main collision points to be with these patches.

mmmigration-take-a-reference-to-the-anon_vma-before-migrating.patch
mmmigration-share-the-anon_vma-ref-counts-between-ksm-and-page-migration.patch

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
