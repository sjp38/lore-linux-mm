Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 943B16B0062
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 21:21:08 -0400 (EDT)
Date: Thu, 14 Jun 2012 03:21:03 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: do not use page_count without a page pin
Message-ID: <20120614012103.GY3094@redhat.com>
References: <1339373872-31969-1-git-send-email-minchan@kernel.org>
 <4FD59C31.6000606@jp.fujitsu.com>
 <20120611074440.GI3094@redhat.com>
 <20120611133043.GA2340@barrios>
 <20120611144132.GT3094@redhat.com>
 <4FD675FE.1060202@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FD675FE.1060202@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On Tue, Jun 12, 2012 at 07:49:34AM +0900, Minchan Kim wrote:
> If THP page isn't LRU and it's still PageTransHuge, I think it's rather rare and
> although it happens, it means migration/reclaimer is about to split or isolate/putback
> so it ends up making THP page movable pages.
> 
> IMHO, it would be better to account it by movable pages.
> What do you think about it?

Agreed. Besides THP don't fragment pageblocks. It was just about
speeding up the scanning the same way it happens with the pagebuddy
check, but probably not worth it because we're in a racy area here not
holding locks. pagebuddy is safe because the zone lock is hold, or
it'd run in the same problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
