Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D11618D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 20:33:28 -0500 (EST)
Date: Mon, 7 Feb 2011 17:28:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Add hook of freepage
Message-Id: <20110207172806.dbca2cae.akpm@linux-foundation.org>
In-Reply-To: <1297071421.25994.58.camel@tucsk.pomaz.szeredi.hu>
References: <1297004934-4605-1-git-send-email-minchan.kim@gmail.com>
	<1297071421.25994.58.camel@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <mszeredi@suse.cz>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>

On Mon, 07 Feb 2011 10:37:01 +0100
Miklos Szeredi <mszeredi@suse.cz> wrote:

> On Mon, 2011-02-07 at 00:08 +0900, Minchan Kim wrote:
> > Recently, "Call the filesystem back whenever a page is removed from
> > the page cache(6072d13c)" added new freepage hook in page cache
> > drop function.
> > 
> > So, replace_page_cache_page should call freepage to support
> > page cleanup to fs.
> 
> Thanks Minchan for fixing this.

What's happening with mm-add-replace_page_cache_page-function.patch,
btw?  When last discussed nearly three weeks ago we had identified:

1) remove radix_tree_preload
2) single radix_tree_lookup_slot and replace radix tree slot
3) page accounting optimization if both pages are in same zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
