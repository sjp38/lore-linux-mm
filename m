Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 23A3E8D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 17:45:47 -0500 (EST)
Date: Wed, 23 Feb 2011 14:44:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: optimize replace_page_cache_page
Message-Id: <20110223144445.86d0ca2b.akpm@linux-foundation.org>
In-Reply-To: <20110219234121.GA2546@barrios-desktop>
References: <1297355626-5152-1-git-send-email-minchan.kim@gmail.com>
	<20110219234121.GA2546@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Miklos Szeredi <mszeredi@suse.cz>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>

On Sun, 20 Feb 2011 08:41:21 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Resend.

Reignore.

> he patch is based on mmotm-2011-02-04 + 
> mm-add-replace_page_cache_page-function-add-freepage-hook.patch.
> 
> On Fri, Feb 11, 2011 at 01:33:46AM +0900, Minchan Kim wrote:
> > This patch optmizes replace_page_cache_page.
> > 
> > 1) remove radix_tree_preload
> > 2) single radix_tree_lookup_slot and replace radix tree slot
> > 3) page accounting optimization if both pages are in same zone.
> > 
> > Cc: Miklos Szeredi <mszeredi@suse.cz>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  mm/filemap.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++---------
> >  1 files changed, 51 insertions(+), 10 deletions(-)
> > 
> > Hi Miklos,
> > This patch is totally not tested.
> > Could you test this patch?

^^^ Because of this.

Is it tested yet?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
