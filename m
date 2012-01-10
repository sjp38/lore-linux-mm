Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 739606B005C
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 11:57:47 -0500 (EST)
Date: Tue, 10 Jan 2012 16:57:43 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: vmscan: no change of reclaim mode if unevictable
 page encountered
Message-ID: <20120110165743.GE4118@suse.de>
References: <CAJd=RBDAoNt=TZWhNeLs0MaCJ_ormEp=ya55-PA+B0BAxfGbbQ@mail.gmail.com>
 <20120110094026.GB4118@suse.de>
 <CAJd=RBBNK6P=Kq09G88UDEsiU8KUPiko5WTfLgQqKzry8tVH5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBBNK6P=Kq09G88UDEsiU8KUPiko5WTfLgQqKzry8tVH5A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 11, 2012 at 12:27:53AM +0800, Hillf Danton wrote:
> On Tue, Jan 10, 2012 at 5:40 PM, Mel Gorman <mgorman@suse.de> wrote:
> > On Sat, Jan 07, 2012 at 11:46:17AM +0800, Hillf Danton wrote:
> >> Since unevictable page is not isolated from lru list for shrink_page_list(),
> >> it is accident if encountered in shrinking, and no need to change reclaim mode.
> >>
> >
> > This changelog does does not explain the problem, does not explain
> > what is fixed or what the impact is.
> >
> > It also does not make sense. It says "unevictable page is not isolated
> > from LRU list" but this is shrink_page_list() and the page has already
> > been isolated (probably by lumpy reclaim). It will be put back on
> > the LRU_UNEVICTABLE list.
> >
> > It might be the case that resetting the reclaim mode after encountering
> > mlocked pages is overkill but that would need more justification than
> > what this changelog offers. Resetting the mode impacts THP rates but
> > this is erring on the side of caution by doing less work in reclaim
> > as the savings from THP may not offset the cost of reclaim.
> >
> 
> Hi Mel
> 
> It is reprepared, please review again.
> 
> Thanks
> Hillf
> 
> ===cut please===
> From: Hillf Danton <dhillf@gmail.com>
> [PATCH] mm: vmscan: no change of reclaim mode if unevictable page encountered
> 
> Unevictable pages are not isolated from lru list for shrink_page_list(), and
> they could be put back onto lru list if accidentally encountered in shrinking.
> 
> But resetting reclaim mode maybe overkill, as it impacts THP rates. This is
> erring on the side of caution by doing less work in reclaim as the savings
> from THP may not offset the cost of reclaim.
> 

When I said it needed more justification, I meant that you need to show
a workload or usecase that suffers as a result of reset_reclaim_mode
being called here. I explained already that the reset errs on the
side of caution by making reclaim work less.

You need to describe what problem your workload is suffering from and
why this patch fixes it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
