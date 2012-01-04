Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id F03FA6B00B9
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 20:23:38 -0500 (EST)
Received: by yenq10 with SMTP id q10so10935678yen.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 17:23:38 -0800 (PST)
Date: Wed, 4 Jan 2012 10:23:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] mm: test PageSwapBacked in lumpy reclaim
Message-ID: <20120104012334.GB18399@barrios-laptop.redhat.com>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
 <alpine.LSU.2.00.1112282033260.1362@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1112282033260.1362@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, Dec 28, 2011 at 08:35:13PM -0800, Hugh Dickins wrote:
> Lumpy reclaim does well to stop at a PageAnon when there's no swap, but
> better is to stop at any PageSwapBacked, which includes shmem/tmpfs too.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>  

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
