Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 092496B005A
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 04:40:31 -0500 (EST)
Date: Tue, 10 Jan 2012 09:40:27 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: vmscan: no change of reclaim mode if unevictable
 page encountered
Message-ID: <20120110094026.GB4118@suse.de>
References: <CAJd=RBDAoNt=TZWhNeLs0MaCJ_ormEp=ya55-PA+B0BAxfGbbQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBDAoNt=TZWhNeLs0MaCJ_ormEp=ya55-PA+B0BAxfGbbQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Jan 07, 2012 at 11:46:17AM +0800, Hillf Danton wrote:
> Since unevictable page is not isolated from lru list for shrink_page_list(),
> it is accident if encountered in shrinking, and no need to change reclaim mode.
> 

This changelog does does not explain the problem, does not explain
what is fixed or what the impact is.

It also does not make sense. It says "unevictable page is not isolated
from LRU list" but this is shrink_page_list() and the page has already
been isolated (probably by lumpy reclaim). It will be put back on
the LRU_UNEVICTABLE list.

It might be the case that resetting the reclaim mode after encountering
mlocked pages is overkill but that would need more justification than
what this changelog offers. Resetting the mode impacts THP rates but
this is erring on the side of caution by doing less work in reclaim
as the savings from THP may not offset the cost of reclaim.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
