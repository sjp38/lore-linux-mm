Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id EFAA76B006E
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 19:22:01 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7192530pbb.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 16:22:01 -0700 (PDT)
Date: Sat, 16 Jun 2012 08:21:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: clear pages_scanned only if draining a pcp adds
 pages to the buddy allocator again
Message-ID: <20120615232151.GA2749@barrios>
References: <1339690570-7471-1-git-send-email-kosaki.motohiro@gmail.com>
 <4FDAE1F0.4030708@kernel.org>
 <4FDB5A42.9020707@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FDB5A42.9020707@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Fri, Jun 15, 2012 at 11:52:34AM -0400, KOSAKI Motohiro wrote:
> (6/15/12 3:19 AM), Minchan Kim wrote:
> >On 06/15/2012 01:16 AM, kosaki.motohiro@gmail.com wrote:
> >
> >>From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> >>
> >>commit 2ff754fa8f (mm: clear pages_scanned only if draining a pcp adds pages
> >>to the buddy allocator again) fixed one free_pcppages_bulk() misuse. But two
> >>another miuse still exist.
> >>
> >>This patch fixes it.
> >>
> >>Cc: David Rientjes<rientjes@google.com>
> >>Cc: Mel Gorman<mel@csn.ul.ie>
> >>Cc: Johannes Weiner<hannes@cmpxchg.org>
> >>Cc: Minchan Kim<minchan.kim@gmail.com>
> >>Cc: Wu Fengguang<fengguang.wu@intel.com>
> >>Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> >>Cc: Rik van Riel<riel@redhat.com>
> >>Cc: Andrew Morton<akpm@linux-foundation.org>
> >>Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> >
> >Reviewed-by: Minchan Kim<minchan@kernel.org>
> >
> >Just nitpick.
> >Personally, I want to fix it follwing as
> >It's more simple and reduce vulnerable error in future.
> >
> >If you mind, go ahead with your version. I am not against with it, either.
> 
> I don't like your version because free_pcppages_bulk() can be called from
> free_pages() hotpath. then, i wouldn't like to put a branch if we can avoid it.

Fair enough.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
