Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DB820600385
	for <linux-mm@kvack.org>; Thu, 27 May 2010 09:44:23 -0400 (EDT)
Received: by pvg4 with SMTP id 4so204075pvg.14
        for <linux-mm@kvack.org>; Thu, 27 May 2010 06:44:22 -0700 (PDT)
Date: Thu, 27 May 2010 22:44:13 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/5] rename anon_vma_lock to vma_lock_anon_vma
Message-ID: <20100527134413.GA2112@barrios-desktop>
References: <20100526153819.6e5cec0d@annuminas.surriel.com>
 <20100526153853.55b72183@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526153853.55b72183@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 03:38:53PM -0400, Rik van Riel wrote:
> Subject: rename anon_vma_lock to vma_lock_anon_vma
> 
> Rename anon_vma_lock to vma_lock_anon_vma.  This matches the
> naming style used in page_lock_anon_vma and will come in really
> handy further down in this patch series.
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
