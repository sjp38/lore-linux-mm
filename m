Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id B4D566B004D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 11:45:30 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1829297pbb.14
        for <linux-mm@kvack.org>; Wed, 25 Jul 2012 08:45:30 -0700 (PDT)
Date: Wed, 25 Jul 2012 08:45:26 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 15/34] mm: migration: clean up unmap_and_move()
Message-ID: <20120725154526.GA18901@kroah.com>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
 <1343050727-3045-16-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343050727-3045-16-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Stable <stable@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 23, 2012 at 02:38:28PM +0100, Mel Gorman wrote:
> commit 0dabec93de633a87adfbbe1d800a4c56cd19d73b upstream.
> 
> Stable note: Not tracked in Bugzilla. This patch makes later patches
> 	easier to apply but has no other impact.
> 
> unmap_and_move() is one a big messy function.  Clean it up.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> ---
>  mm/migrate.c |   59 ++++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 33 insertions(+), 26 deletions(-)

Mel, you didn't sign-off-on this patch.  Any reason why?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
