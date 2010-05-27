Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F124D600385
	for <linux-mm@kvack.org>; Thu, 27 May 2010 09:55:17 -0400 (EDT)
Received: by pwi6 with SMTP id 6so4219pwi.14
        for <linux-mm@kvack.org>; Thu, 27 May 2010 06:55:15 -0700 (PDT)
Date: Thu, 27 May 2010 22:55:07 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 4/5] always lock the root (oldest) anon_vma
Message-ID: <20100527135356.GD2112@barrios-desktop>
References: <20100526153819.6e5cec0d@annuminas.surriel.com>
 <20100526154044.2769e707@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526154044.2769e707@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 03:40:44PM -0400, Rik van Riel wrote:
> Subject: always lock the root (oldest) anon_vma
> 
> Always (and only) lock the root (oldest) anon_vma whenever we do something in an
> anon_vma.  The recently introduced anon_vma scalability is due to the rmap code
> scanning only the VMAs that need to be scanned.  Many common operations still
> took the anon_vma lock on the root anon_vma, so always taking that lock is not
> expected to introduce any scalability issues.
> 
> However, always taking the same lock does mean we only need to take one lock,
> which means rmap_walk on pages from any anon_vma in the vma is excluded from
> occurring during an munmap, expand_stack or other operation that needs to
> exclude rmap_walk and similar functions.
> 
> Also add the proper locking to vma_adjust.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nitpick:

It would be better to modify comment about head of anon_vma in rmap.h, too.
/*  
 * NOTE: the LSB of the head.next is set by
                   ->   root->hext.next 
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
