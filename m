Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id BFCF16B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 10:44:03 -0400 (EDT)
Date: Thu, 15 Mar 2012 15:44:00 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: hugetlb: defer freeing pages when gathering surplus
 pages
Message-ID: <20120315144400.GA19855@tiehlicka.suse.cz>
References: <CAJd=RBATj97k5UESDFx82bzt0K4OquhBoDkfjPBPacdmdfJE8g@mail.gmail.com>
 <20120314111357.GD4434@tiehlicka.suse.cz>
 <CAJd=RBBd0vF1waARU5FQbomLQLAG5ekmiWg+WDpALke9SaGP1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBBd0vF1waARU5FQbomLQLAG5ekmiWg+WDpALke9SaGP1g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 14-03-12 21:08:13, Hillf Danton wrote:
> On Wed, Mar 14, 2012 at 7:13 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > [Sorry for the late reply but I was away from email for quite sometime]
> >
> 
> Nice to see you back:)

Thanks

> 
> > On Tue 14-02-12 20:53:51, Hillf Danton wrote:
> >> When gathering surplus pages, the number of needed pages is recomputed after
> >> reacquiring hugetlb lock to catch changes in resv_huge_pages and
> >> free_huge_pages. Plus it is recomputed with the number of newly allocated
> >> pages involved.
> >>
> >> Thus freeing pages could be deferred a bit to see if the final page request is
> >> satisfied, though pages could be allocated less than needed.
> >
> > The patch looks OK but I am missing a word why we need it. I guess
> 
> False negative is removed as it should be.

Right, I meant false negative. Would be nice to have it in the
changelog... Anyway, Andrew has already picked up the patch I guess.
Just in case

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> > your primary motivation is that we want to reduce false positives when
> > we fail to allocate surplus pages while somebody freed some in the
> > background.
> > What is the workload that you observed such a behavior? Or is this just
> > from the code review?
> >
> The second.

OK

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
