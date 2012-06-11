Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A9EEB6B0129
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 09:44:36 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6680381dak.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 06:44:36 -0700 (PDT)
Date: Mon, 11 Jun 2012 22:44:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: clean up __count_immobile_pages
Message-ID: <20120611134409.GA2707@barrios>
References: <1339380442-1137-1-git-send-email-minchan@kernel.org>
 <4FD59952.7020602@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FD59952.7020602@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On Mon, Jun 11, 2012 at 04:08:02PM +0900, Kamezawa Hiroyuki wrote:
> (2012/06/11 11:07), Minchan Kim wrote:
> >__count_immobile_pages naming is rather awkward.
> >This patch clean up the function and add comment.
> >
> >Cc: Mel Gorman<mgorman@suse.de>
> >Cc: Michal Hocko<mhocko@suse.cz>
> >Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> >Signed-off-by: Minchan Kim<minchan@kernel.org>
> 
> exchange true<->false caused by renaming ?

Exactly.

> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks, Kame.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
