Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 3B8D26B004D
	for <linux-mm@kvack.org>; Fri, 30 Dec 2011 10:51:32 -0500 (EST)
Date: Fri, 30 Dec 2011 15:51:27 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
Message-ID: <20111230155127.GG15729@suse.de>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
 <alpine.LSU.2.00.1112282037000.1362@eggly.anvils>
 <20111229145548.e34cb2f3.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1112291510390.4888@eggly.anvils>
 <4EFD04B2.7050407@gmail.com>
 <alpine.LSU.2.00.1112291753350.3614@eggly.anvils>
 <20111229195917.13f15974.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111229195917.13f15974.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Thu, Dec 29, 2011 at 07:59:17PM -0800, Andrew Morton wrote:
> <SNIP>
>
> Now, a way out here is to remove lumpy reclaim (please).  And make the
> problem not come back by promising to never call putback_lru_pages(lots
> of pages) (how do we do this?).
> 
> So I think the best way ahead here is to distribute this patch in the
> same release in which we remove lumpy reclaim (pokes Mel).
> 

I'll take a look at this in the New Years. Removing lumpy reclaim is
straight-forward. Making sure that it does not ruin THP allocation
success rates will be the time consuming part.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
