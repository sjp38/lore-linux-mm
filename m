Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 95C00600385
	for <linux-mm@kvack.org>; Thu, 27 May 2010 10:31:43 -0400 (EDT)
Received: by pzk11 with SMTP id 11so32165pzk.28
        for <linux-mm@kvack.org>; Thu, 27 May 2010 07:31:42 -0700 (PDT)
Date: Thu, 27 May 2010 23:31:34 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 5/5] extend KSM refcounts to the anon_vma root
Message-ID: <20100527143134.GA9505@barrios-desktop>
References: <20100526153819.6e5cec0d@annuminas.surriel.com>
 <20100526154124.04607d04@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526154124.04607d04@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
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
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Now I understand this patch. 
Thanks, Rik. 
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
