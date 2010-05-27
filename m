Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D6F1D600385
	for <linux-mm@kvack.org>; Thu, 27 May 2010 09:46:45 -0400 (EDT)
Received: by pwi6 with SMTP id 6so353381pwi.14
        for <linux-mm@kvack.org>; Thu, 27 May 2010 06:46:44 -0700 (PDT)
Date: Thu, 27 May 2010 22:46:31 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/5] change direct call of spin_lock(anon_vma->lock) to
 inline function
Message-ID: <20100527134631.GB2112@barrios-desktop>
References: <20100526153819.6e5cec0d@annuminas.surriel.com>
 <20100526153926.1272945b@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526153926.1272945b@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 03:39:26PM -0400, Rik van Riel wrote:
> Subject: change direct call of spin_lock(anon_vma->lock) to inline function
> 
> Subsitute a direct call of spin_lock(anon_vma->lock) with
> an inline function doing exactly the same.
> 
> This makes it easier to do the substitution to the root
> anon_vma lock in a following patch.
> 
> We will deal with the handful of special locks (nested,
> dec_and_lock, etc) separately.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
