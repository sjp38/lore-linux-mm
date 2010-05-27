Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B65636B01B2
	for <linux-mm@kvack.org>; Thu, 27 May 2010 13:50:59 -0400 (EDT)
Date: Thu, 27 May 2010 18:50:38 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/5] extend KSM refcounts to the anon_vma root
Message-ID: <20100527175038.GB10931@csn.ul.ie>
References: <20100526153819.6e5cec0d@annuminas.surriel.com> <20100526154124.04607d04@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100526154124.04607d04@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 03:41:24PM -0400, Rik van Riel wrote:
> Subject: extend KSM refcounts to the anon_vma root
> 
> KSM reference counts can cause an anon_vma to exist after the processe
> it belongs to have already exited.  Because the anon_vma lock now lives
> in the root anon_vma, we need to ensure that the root anon_vma stays
> around until after all the "child" anon_vmas have been freed.
> 
> The obvious way to do this is to have a "child" anon_vma take a
> reference to the root in anon_vma_fork.  When the anon_vma is freed
> at munmap or process exit, we drop the refcount in anon_vma_unlink
> and possibly free the root anon_vma.
> 
> The KSM anon_vma reference count function also needs to be modified
> to deal with the possibility of freeing 2 levels of anon_vma.  The
> easiest way to do this is to break out the KSM magic and make it
> generic.
> 
> When compiling without CONFIG_KSM, this code is compiled out.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
